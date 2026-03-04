{inputs, ...}: {
  config,
  lib,
  pkgs,
  ...
}: {
  options.cow.cocoon = {
    enable = lib.mkEnableOption "Cocoon PDS";
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
    relays = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Relay servers to use for event syncing";
      default = ["https://bsky.network"];
    };
    fallbackProxy = lib.mkOption {
      type = lib.types.str;
      description = "Proxy for xrpc requests that we can't service";
      default = "did:web:api.bsky.app#bsky_appview";
    };
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "Public facing hostname for the server";
    };
    favicon = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      description = "Path to favicon file to serve";
      default = null;
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
              add_header access-control-allow-headers "authorization,dpop,atproto-accept-labelers,atproto-proxy" always;
              add_header access-control-allow-origin "*" always;
              add_header X-Frame-Options SAMEORIGIN always;
              add_header X-Content-Type-Options nosniff;
            '';
          };
        in {
          "/xrpc/app.bsky.unspecced.getAgeAssuranceState" = mkAgeAssured {
            lastInitiatedAt = "2026-01-19T05:59:50.391Z";
            status = "assured";
          };
          "/xrpc/app.bsky.ageassurance.getConfig" = mkAgeAssured {
            regions = [];
          };
          "/xrpc/app.bsky.ageassurance.getState" = mkAgeAssured {
            state = {
              lastInitiatedAt = "2026-01-19T05:59:50.391Z";
              status = "assured";
              access = "full";
            };
            metadata = {
              accountCreatedAt = "2026-01-19T05:59:50.391Z";
            };
          };
          "/favicon.ico" = lib.mkIf (conf.favicon != null) {
            root = builtins.dirOf conf.favicon;
            tryFiles = "${builtins.baseNameOf conf.favicon} =404";
          };

          # pass everything else to the pds
          "/" = {
            proxyPass = "http://localhost:${toString conf.port}";
            proxyWebsockets = true;
            extraConfig = ''
              add_header access-control-allow-headers "authorization,dpop,atproto-accept-labelers,atproto-proxy" always;
            '';
          };
        };
      };

      services.cocoon = {
        enable = true;
        environmentFiles = [
          conf.adminPassPath
          conf.sessionSecretPath
        ];
        settings = lib.mapAttrsToList (k: v: "COCOON_${k}=${v}") {
          JWK_PATH = conf.jwkPath;
          ROTATION_KEY_PATH = conf.rotationPath;

          DID = conf.did;
          HOSTNAME = conf.hostname;
          ADDR = ":${builtins.toString conf.port}";
          CONTACT_EMAIL = conf.email;

          RELAYS = lib.join "," conf.relays;
          FALLBACK_PROXY = conf.fallbackProxy;

          DB_TYPE = "sqlite";
          DB_NAME = "${conf.dataDir}/cocoon.db";
        };
      };
    };
}
