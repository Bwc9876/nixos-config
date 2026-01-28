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
        serverAliases = [".${conf.hostname}"];

        # All stolen from Isabel
        # https://github.com/isabelroses/dotfiles/blob/262ae19c1e92be5d759f40020e894113ba5d5d44/modules/nixos/services/pds/default.nix
        locations = let
          mkAgeAssured = state: {
            return = "200 '${builtins.toJSON state}'";
            extraConfig = ''
              default_type application/json;
            '';
          };
        in {
          "/xrpc/app.bsky.unspecced.getAgeAssuranceState" = mkAgeAssured {
            lastInitiatedAt = "2025-07-14T15:11:05.487Z";
            status = "assured";
          };
          "/xrpc/app.bsky.ageassurance.getConfig" = mkAgeAssured {
            regions = [];
          };
          "/xrpc/app.bsky.ageassurance.getState" = mkAgeAssured {
            state = {
              lastInitiatedAt = "2025-07-14T15:11:05.487Z";
              status = "assured";
              access = "full";
            };
            metadata = {
              accountCreatedAt = "2022-11-17T00:35:16.391Z";
            };
          };

          # pass everything else to the pds
          "/" = {
            proxyPass = "http://localhost:${toString conf.port}";
            proxyWebsockets = true;
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
          COCOON_ADMIN_PASSWORD=$(cat "$CREDENTIALS_DIRECTORY/adminPass") \
          COCOON_SESSION_SECRET=$(cat "$CREDENTIALS_DIRECTORY/session") \
          ${lib.getExe pkgs.cocoon} run
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
            RELAYS = lib.join "," [
              "https://bsky.network"
              "https://relay.cerulea.blue"
              "https://relay.fire.hose.cam"
              "https://relay2.fire.hose.cam"
              "https://relay3.fr.hose.cam"
              "https://relay.hayescmd.net"
              "https://relay.xero.systems"
              "https://relay.upcloud.world"
              "https://relay.feeds.blue"
              "https://atproto.africa"
              "https://relay.whey.party"
            ];

            # TODO: Don't?
            FALLBACK_PROXY = "did:web:api.bsky.app#bsky_appview";

            JWK_PATH = "%d/jwt";
            ROTATION_KEY_PATH = "%d/rotation";

            DB_TYPE = "sqlite";
            DB_NAME = "${conf.dataDir}/cocoon.db";
          };
        };
      };
    };
}
