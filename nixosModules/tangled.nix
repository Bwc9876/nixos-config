{
  config,
  lib,
  ...
}: {
  options.cow.tangled = {
    email = lib.mkOption {
      type = lib.types.str;
      description = "email to use for contact";
    };
    spindle = {
      enable = lib.mkEnableOption "tangled spindle service";
      port = lib.mkOption {
        type = lib.types.port;
        default = 6555;
        description = "port to run spindle on";
      };
      hostname = lib.mkOption {
        type = lib.types.str;
        description = "virtual host for spindle";
      };
      keyPath = lib.mkOption {
        type = lib.types.str;
        description = "path to spindle key";
      };
    };
    knot = {
      enable = lib.mkEnableOption "tangled knot-rs service";
      hostname = lib.mkOption {
        type = lib.types.str;
        description = "virtual host for knot";
      };
      envFile = lib.mkOption {
        type = lib.types.str;
        description = "path to env file with master key";
      };
      stateDir = lib.mkOption {
        type = lib.types.str;
        description = "runtime path to store all state for the knot";
        default = "/var/lib/knot";
      };
    };
  };

  config = let
    conf = config.cow.tangled;
  in {
    cow.imperm.keep =
      ["/var/lib/tangled-knot"]
      ++ (lib.optional conf.knot.enable conf.knot.stateDir)
      ++ (lib.optionals conf.spindle.enable ["/var/lib/spindle" "/var/lib/docker"]);

    services.tangled = {
      knot-rs = lib.mkIf conf.knot.enable {
        enable = true;
        inherit (conf.knot) stateDir;
        openFirewall = true;
        environmentFile = conf.knot.envFile;
        settings = {
          git.object_format = "sha1";
          server = {
            hostname = lib.mkDefault conf.knot.hostname;
            admins = lib.mkIf config.cow.bean.enable (lib.mkDefault [config.cow.bean.atproto.did]);
            ssh_listen_addr = "[::]:22";
          };
          contact.email = conf.email;
          lfs.store_path = "${conf.knot.stateDir}/lfs";
          atproto.plc_directory = "https://plc.directory";
          atproto.repo_signing_keys = "${conf.knot.stateDir}/repo-signing-keys.json";
          xrpc = {
            trusted_proxy_header = "x-forwarded-for";
            trusted_proxies = ["127.0.0.1" "::1"];
          };
        };
      };
      # knot = lib.mkIf conf.knot.enable {
      #   enable = true;
      #   openFirewall = lib.mkDefault false;
      #   inherit (conf.knot) gitUser stateDir;
      #   repo.scanPath = "${conf.knot.stateDir}/repos";
      #   server = {
      #     listenAddr = "0.0.0.0:${builtins.toString conf.knot.port}";
      #     internalListenAddr = "127.0.0.1:${builtins.toString conf.knot.internalPort}";
      #     hostname = lib.mkDefault conf.knot.hostname;
      #     owner = lib.mkIf config.cow.bean.enable (lib.mkDefault config.cow.bean.atproto.did);
      #   };
      # };
      spindle = lib.mkIf conf.spindle.enable {
        enable = true;
        inherit (conf.spindle) keyPath;
        contact.email = conf.email;
        server = {
          listenAddr = "0.0.0.0:${builtins.toString conf.spindle.port}";
          owner = lib.mkIf config.cow.bean.enable (lib.mkDefault config.cow.bean.atproto.did);
          hostname = lib.mkDefault conf.spindle.hostname;
        };
      };
    };

    services.nginx.virtualHosts = {
      ${conf.knot.hostname} = lib.mkIf conf.knot.enable {
        locations = {
          "/" = {
            proxyPass = "http://localhost:5555";
            recommendedProxySettings = true;
          };
          "/events" = {
            proxyPass = "http://localhost:5555";
            proxyWebsockets = true;
            recommendedProxySettings = true;
          };
        };
      };

      ${conf.spindle.hostname} = lib.mkIf conf.spindle.enable {
        locations = {
          "/" = {
            proxyPass = "http://localhost:${builtins.toString conf.spindle.port}";
            recommendedProxySettings = true;
          };
          "/events" = {
            proxyPass = "http://localhost:${builtins.toString conf.spindle.port}";
            proxyWebsockets = true;
            recommendedProxySettings = true;
          };
          "/logs" = {
            proxyPass = "http://localhost:${builtins.toString conf.spindle.port}";
            proxyWebsockets = true;
            recommendedProxySettings = true;
          };
        };
      };
    };

    # For Spindle
    boot.kernelModules = lib.optional conf.spindle.enable "vhost_vsock";

    services.openssh = lib.mkIf conf.knot.enable {
      enable = true;
    };
  };
}
