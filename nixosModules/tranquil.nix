{inputs, ...}: {
  config,
  lib,
  pkgs,
  ...
}: {
  options.cow.cocoon = {
    enable = lib.mkEnableOption "Cocoon PDS with postgresql";
    port = lib.mkOption {
      type = lib.types.port;
      description = "Port to bind to";
      default = 3000;
    };
    userName = lib.mkOption {
      type = lib.types.str;
      description = "User name to create and use for the service. ALSO used as the database name!";
      default = "cocoon";
    };
    dataDir = lib.mkOption {
      type = lib.types.str;
      description = "Runtime path to store data at";
      default = "/var/lib/cocoon";
    };
    secretsDir = {
      type = lib.types.str;
      description = ''
        Runtime path with secret keys in files. Files map to env vars as follows:

        - jwt.key -> JWT_SECRET
        - dpop.key -> DPOP_SECRET
        - master.key -> MASTER_KEY

        This will not implicitly persist this directory
      '';
      example = "/var/lib/cocoon/keys";
    };
    metadata.email = lib.mkOption {
      type = lib.types.str;
      description = "Contact email for this PDS' administrator";
    };
    ageAssuranceOverride = lib.mkEnableOption "override age assurance on the app view";
    acceptRepoImports = lib.mkEnableOption "accepting repository imports";
    inviteCodeRequired = lib.mkEnableOption "requiring invite codes to register";
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "Public facing hostname for the server";
    };
  };

  config = let
    conf = config.cow.cocoon;
  in
    lib.mkIf conf.enable {
      cow.imperm.keep = [config.services.postgresql.dataDir conf.dataDir];

      users.users.${conf.userName} = {
        isSystemUser = true;
        useDefaultShell = true;
        home = conf.dataDir;
        createHome = true;
        group = conf.userName;
      };

      users.groups.${conf.userName} = {};

      services.postgresql = {
        enable = true;
        ensureDatabases = [conf.userName];
        ensureUsers.${conf.userName} = {
          name = conf.userName;
          ensureDBOwnsership = true;
        };
      };

      systemd.services.cocoon = let
        blobPath = "${conf.dataDir}/blobs";
        backupPath = "${conf.dataDir}/backups";
        dbUrl = "postgres:///${conf.userName}?host=/var/run/postgresql";
      in {
        description = "Tranquil PDS";
        after = ["network.target"];
        wantedBy = ["multi-user.target"];
        enableStrictShellChecks = true;

        preStart = ''
          mkdir -p "${conf.dataDir}" "${blobPath}" "${backupPath}"
          echo "Running Migrations..."
          ${lib.getExe pkgs.sqlx-cli} migrate run --source "${inputs.cocoon.outPath}/migrations" -D ${dbUrl}
          echo "Complete."
          chown -R ${conf.userName}:${conf.userName} "${conf.dataDir}"
        '';

        script = ''
          JWT_SECRET=$(cat $CREDENTIALS_DIRECTORY/jtw.key)  \
          DPOP_SECRET=$(cat $CREDENTIALS_DIRECTORY/dpop.key) \
          MASTER_KEY=$(cat $CREDENTIALS_DIRECTORY/master.key) \
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
          LoadCredential = builtins.map (v: "${v}:${conf.secretsDir}/${v}.key") [
            "jwt"
            "dpop"
            "master"
          ];
          Environment = let
            boolToEnv = b:
              if b
              then "1"
              else "0";
          in
            lib.mapAttrsToList (k: v: "${k}=${v}") {
              SERVER_HOST = "127.0.0.1";
              SERVER_PORT = builtins.toString conf.port;

              PDS_HOSTNAME = conf.hostname;
              DATABASE_URL = dbUrl;

              BLOB_STORAGE_PATH = blobPath;
              BACKUP_STORAGE_PATH = backupPath;

              ACCEPTING_REPO_IMPORTS = boolToEnv conf.acceptRepoImports;
              INVITE_CODE_REQUIRED = boolToEnv conf.inviteCodeRequired;
              CONTACT_EMAIL = conf.metadata.email;
              PDS_AGE_ASSURANCE_OVERRIDE = boolToEnv conf.ageAssuranceOverride;
            };
        };
      };
    };
}
