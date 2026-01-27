{inputs, ...}: {
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [inputs.tangled.nixosModules.knot];

  options.cow.tangled = {
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "virtual host for knot and spindle";
      default = "knot.bwc9876.dev";
    };
    knot = {
      enable = lib.mkEnableOption "tangled knot service";
    };
  };

  config = let
    conf = config.cow.tangled;
    knotStateDir = "/var/lib/tangled-knot";
    gitUser = "gurt";
  in {
    cow.imperm.keep = lib.optional conf.knot.enable knotStateDir;

    services.tangled = {
      knot = lib.mkIf conf.knot.enable {
        enable = true;
        openFirewall = false;
        inherit gitUser;
        stateDir = knotStateDir;
        repo.scanPath = "${config.services.tangled.knot.stateDir}/repos";
        motdFile = ../res/bleh.txt;
        server = {
          # Pub Port: 5555, Internal Port: 5444
          hostname = lib.mkDefault conf.hostname;
          owner = lib.mkIf config.cow.bean.enable (lib.mkDefault config.cow.bean.atproto.did);
        };
      };
    };

    services.nginx.virtualHosts.${conf.hostname} = lib.mkIf conf.knot.enable {
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

    services.openssh = lib.mkIf conf.knot.enable {
      enable = true;
    };
  };
}
