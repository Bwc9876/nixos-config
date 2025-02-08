{
  inputs,
  config,
  ...
}: {
  environment.variables."HOSTNAME" = config.networking.hostName;
  environment.etc."flake-src".source = inputs.self;
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}
