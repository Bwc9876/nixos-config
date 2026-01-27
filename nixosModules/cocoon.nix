{inputs, ...}: {
  config,
  lib,
  pkgs,
  ...
}: {
  options.cow.cocoon = {
    enable = lib.mkEnableOption "Cocoon PDS with postgresql";
    did = lib.mkOption {
      type = lib.types.str;
      description = "DID of server owner";
    };
    port = lib.mkOption {
      type = lib.types.port;
      description = "Port to bind to";
      default = 8080;
    };
    userName = lib.mkOption {
      type = lib.types.str;
      description = "User name to create and use for the service.";
      default = "cocoon";
    };
    dataDir = lib.mkOption {
      type = lib.types.str;
      description = "Runtime path to store data at";
      default = "/var/lib/cocoon";
    };
    jwkPath = lib.mkOption {
      type = lib.types.str;
      description = "Runtime path of the JWK key";
    };
    rotationPath = lib.mkOption {
      type = lib.types.str;
      description = "Runtime path of the rotation key";
    };
    sessionSecretPath = lib.mkOption {
      type = lib.types.str;
      description = "Runtime path of the session secret";
    };
    adminPassPath = lib.mkOption {
      type = lib.types.str;
      description = "Runtime path of the admin password";
    };
    email = lib.mkOption {
      type = lib.types.str;
      description = "Contact email for this PDS' administrator";
    };
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "Public facing hostname for the server";
    };
  };

  config = let
    conf = config.cow.cocoon;
  in
    lib.mkIf conf.enable {
      cow.imperm.keep = [
        conf.dataDir
      ];

      services.nginx.virtualHosts.${conf.hostname} = {
        locations = {
          "/" = {
            proxyPass = "http://localhost:${builtins.toString conf.port}";
            recommendedProxySettings = true;
          };
        };
      };

      users.users.${conf.userName} = {
        isSystemUser = true;
        useDefaultShell = true;
        home = conf.dataDir;
        createHome = true;
        group = conf.userName;
      };

      users.groups.${conf.userName} = {};

      systemd.services.cocoon = {
        description = "Cocoon PDS";
        after = ["network.target"];
        wantedBy = ["multi-user.target"];
        enableStrictShellChecks = true;

        preStart = ''
          mkdir -p "${conf.dataDir}"
          chown -R ${conf.userName}:${conf.userName} "${conf.dataDir}"
        '';

        script = ''
          COCOON_ADMIN_PASSWORD=$(cat $CREDENTIALS_DIRECTORY/adminPass) \
          COCOON_SESSION_SECRET=$(cat $CREDENTIALS_DIRECTORY/session) \
          ${lib.getExe pkgs.cocoon}
        '';

        serviceConfig = {
          User = conf.userName;
          PermissionsStartOnly = true;
          WorkingDirectory = conf.dataDir;
          Restart = "always";
          RestartSec = "5s";
          ProtectSystem = true;
          ProtectHome = true;
          PrivateTmp = true;
          ReadWritePaths = conf.dataDir;
          LoadCredential = [
            "jwt:${conf.jwkPath}"
            "rotation:${conf.rotationPath}"
            "adminPass:${conf.adminPassPath}"
            "session:${conf.sessionSecretPath}"
          ];
          Environment = lib.mapAttrsToList (k: v: "COCOON_${k}=${v}") {
            DID = conf.did;
            HOSTNAME = conf.hostname;
            ADDR = ":${builtins.toString conf.port}";
            CONTACT_EMAIL = conf.email;

            # TODO: Don't hardcode
            RELAYS = "https://bsky.network";

            JWK_PATH = "%d/jwt";
            ROTATION_KEY_PATH = "%d/rotation";

            DB_TYPE = "sqlite";
            DB_NAME = "${conf.dataDir}/cocoon.db";
          };
        };
      };
    };
}
