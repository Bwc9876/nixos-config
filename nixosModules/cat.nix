{
  config,
  lib,
  ...
}: {
  options.cow.cat.enable = lib.mkEnableOption "Catppuccin theming everywhere";

  config = lib.mkIf config.cow.cat.enable {
    catppuccin = {
      enable = true;
      flavor = "mocha";
      accent = "green";
    };
  };
}
