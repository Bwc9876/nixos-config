{
  config,
  lib,
  inputs,
  ...
}: {
  imports = [inputs.catppuccin.homeModules.catppuccin];

  options.cow.cat.enable = lib.mkEnableOption "Catppuccin Home Customizations";

  config = lib.mkIf config.cow.cat.enable {
    catppuccin = {
      enable = true;
      flavor = "mocha";
      accent = "green";
      mako.enable = false;
    };
  };
}
