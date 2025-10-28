{
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  options.cow.cat.enable = lib.mkEnableOption "Catppuccin Home Customizations";

  config = lib.mkIf config.cow.cat.enable {
    catppuccin = {
      enable = true;
      mako.enable = false;
    };
  };
}
