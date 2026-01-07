{...}: {
  pkgs,
  inputs,
  config,
  lib,
  ...
}: {
  options.cow.base = let
    mkDefaultOption = d: (lib.mkEnableOption d) // {default = true;};
  in {
    enable = lib.mkEnableOption "Base niceties and system tweaks. Also sets up some defaults specific to me, but can be easily changed.";
    env = mkDefaultOption "a nice environment setup, sets /etc/machine-id, HOSTNAME, and links flake source code in /etc/flake-src";
    util = mkDefaultOption "Programs needed to rebuild the flake and run just recipes";
    tmp = mkDefaultOption "Clear /tmp on boot and limit RuntimeDirectorySize";
    nix = mkDefaultOption "Nix tweaks: use Lix, mark flake inputs as extra deps, adjust OOM score of the build daemon, expose nixpkgs instance as 'p' in flake registry, turn off channels, etc.";
    boot = mkDefaultOption "systemd in initrd, set kernel lockdown";
    linux-latest = mkDefaultOption "latest Linux kernel";
    sysrqs = lib.mkEnableOption "sysrqs";
  };

  config = let
    conf = config.cow.base;
  in
    lib.mkIf conf.enable (
      lib.mkMerge [
        {
          time.timeZone = lib.mkDefault "America/New_York";
          programs.ssh.startAgent = lib.mkDefault true;
        }
        (lib.mkIf conf.env {
          environment.etc = {
            "machine-id".text = builtins.hashString "md5" config.networking.hostName;
            "flake-src".source = inputs.self;
          };
          environment.variables.HOSTNAME = config.networking.hostName;
        })
        (lib.mkIf conf.util {
          environment.systemPackages = with pkgs; [
            uutils-coreutils-noprefix
            nh
            nix-output-monitor
            git
            just
          ];
        })
        (lib.mkIf conf.tmp {
          boot.tmp.cleanOnBoot = lib.mkDefault true;
          services.logind.settings.Login.RuntimeDirectorySize = lib.mkDefault "100M";
        })
        (lib.mkIf conf.nix {
          # Make Nix builder lower OOM priority so it's killed before other stuff
          systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = lib.mkDefault 250;

          # Keep flake inputs when GC-ing
          system.extraDependencies = with builtins; let
            flakeDeps = flake:
              [flake.outPath] ++ (foldl' (a: b: a ++ b) [] (map flakeDeps (attrValues flake.inputs or {})));
          in
            flakeDeps inputs.self;

          nix = {
            channel.enable = false;
            registry.p.flake = inputs.self;
            package = pkgs.lix;
            settings = {
              # So we can do `import <nixpkgs>`
              nix-path = "nixpkgs=${inputs.nixpkgs}";
              experimental-features = [
                "nix-command"
                "flakes"
                "pipe-operator"
              ];
              auto-optimise-store = true;
              fallback = true;
            };
            gc = {
              automatic = lib.mkDefault false;
              dates = lib.mkDefault "weekly";
            };
          };
        })
        (lib.mkIf conf.boot {
          boot = {
            initrd.systemd.enable = lib.mkDefault true;
            kernelParams = lib.mkDefault ["lockdown=confidentiality"];
          };
        })
        (lib.mkIf conf.linux-latest {
          boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
        })
        (lib.mkIf conf.sysrqs {
          boot.kernel.sysctl."kernel.sysrq" = lib.mkDefault 1;
        })
      ]
    );
}
