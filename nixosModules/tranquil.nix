{
  config,
  lib,
  ...
}: {
  options.cow.tranquil = {
    enable = lib.mkEnableOption "tranquil PDS";
    port = lib.mkOption {
      type = lib.types.port;
      description = "Port to bind to";
      default = 3300;
    };
    envFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to environment file to use for secrets";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      description = "Public hostname for tranquil server";
    };
  };

  config = let
    conf = config.cow.tranquil;
  in
    lib.mkIf conf.enable {
      cow.imperm.keep = [config.services.tranquil-pds.dataDir "/var/lib/postgresql"];

      services.tranquil-pds = {
        enable = true;
        database.createLocally = true;
        environmentFiles = [conf.envFile];

        settings = {
          server = {
            inherit (conf) port;
            hostname = conf.domainName;
            invite_code_required = true;
            age_assurance_override = true;
          };

          firehose.crawlers = [
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
        };
      };

      services.nginx.virtualHosts.${conf.domainName}.locations."/" = {
        proxyPass = "http://127.0.0.1:${toString conf.port}";
        proxyWebsockets = true;
        extraConfig = "client_max_body_size ${toString config.services.tranquil-pds.settings.server.max_blob_size};";
      };
    };
}
