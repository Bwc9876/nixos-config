{...}: {
  pkgs,
  inputs,
  config,
  lib,
  ...
}: {
  time.timeZone = lib.mkDefault "America/New_York";

  environment.etc."machine-id".text = lib.mkDefault (
    builtins.hashString "md5" config.networking.hostName
  );

  environment.variables."HOSTNAME" = lib.mkDefault config.networking.hostName;
  environment.systemPackages = with pkgs; [
    uutils-coreutils-noprefix
    nh
    nix-output-monitor
    git
    just
  ];
  environment.etc."flake-src".source = inputs.self;

  programs.ssh.startAgent = true;
  documentation.man.generateCaches = false;
  services.upower.enable = true;

  boot.tmp.cleanOnBoot = lib.mkDefault true;
  services.logind.settings.Login.RuntimeDirectorySize = lib.mkDefault "100M";

  # Make Nix builder lower OOM priority so it's killed before other stuff
  systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = lib.mkDefault 250;

  # Keep flake inputs when GC-ing
  system.extraDependencies = with builtins; let
    flakeDeps = flake:
      [flake.outPath] ++ (foldl' (a: b: a ++ b) [] (map flakeDeps (attrValues flake.inputs or {})));
  in
    flakeDeps inputs.self;

  boot = {
    initrd.systemd = {
      enable = lib.mkDefault true;
    };

    # Use latest kernel with sysrqs and lockdown enabled
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    kernelParams = lib.mkDefault ["lockdown=confidentiality"];
    kernel.sysctl."kernel.sysrq" = lib.mkDefault 1;
  };

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
}
