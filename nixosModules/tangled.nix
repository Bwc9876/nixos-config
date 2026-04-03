{
  config,
  lib,
  ...
}: {
  options.cow.tangled = {
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
    };
    knot = {
      enable = lib.mkEnableOption "tangled knot service";
      hostname = lib.mkOption {
        type = lib.types.str;
        description = "virtual host for knot";
      };
      gitUser = lib.mkOption {
        type = lib.types.str;
        description = "Name of git user for SSH operations";
        default = "git";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 5555;
        description = "Port for HTTP traffic to listen on";
      };
      internalPort = lib.mkOption {
        type = lib.types.port;
        default = 5444;
        description = "Port for internal HTTP traffic to listen on";
      };
      stateDir = lib.mkOption {
        type = lib.types.str;
        description = "runtime path to store all state for the knot";
        default = "/var/lib/tangled-knot";
      };
    };
  };

  config = let
    conf = config.cow.tangled;
  in {
    cow.imperm.keep =
      (lib.optional conf.knot.enable conf.knot.stateDir)
      ++ (lib.optionals conf.spindle.enable ["/var/lib/spindle" "/var/lib/docker"]);

    services.tangled = {
      knot = lib.mkIf conf.knot.enable {
        enable = true;
        openFirewall = lib.mkDefault false;
        inherit (conf.knot) gitUser stateDir;
        repo.scanPath = "${conf.knot.stateDir}/repos";
        server = {
          listenAddr = "0.0.0.0:${builtins.toString conf.knot.port}";
          internalListenAddr = "127.0.0.1:${builtins.toString conf.knot.internalPort}";
          hostname = lib.mkDefault conf.knot.hostname;
          owner = lib.mkIf config.cow.bean.enable (lib.mkDefault config.cow.bean.atproto.did);
        };
      };
      spindle = lib.mkIf conf.spindle.enable {
        enable = true;
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
            proxyPass = "http://localhost:${builtins.toString conf.knot.port}";
            recommendedProxySettings = true;
          };
          "/events" = {
            proxyPass = "http://localhost:${builtins.toString conf.knot.port}";
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

    services.openssh = lib.mkIf conf.knot.enable {
      enable = true;
    };
  };
}
