{
  config,
  lib,
  ...
}: {
  options.cow.cat.enable = lib.mkEnableOption "Catppuccin Home Customizations";

  config = lib.mkIf config.cow.cat.enable {
    catppuccin = {
      autoEnable = true;
      enable = true;
      flavor = "mocha";
      accent = "green";
      mako.enable = false;
    };
  };
}
