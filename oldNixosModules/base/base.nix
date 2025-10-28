{
  pkgs,
  inputs,
  config,
  ...
}: {
  environment.variables."HOSTNAME" = config.networking.hostName;
  environment.systemPackages = with pkgs; [
    uutils-coreutils-noprefix
  ];
  environment.etc."flake-src".source = inputs.self;
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}
