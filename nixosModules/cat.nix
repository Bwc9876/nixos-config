{
  config,
  lib,
  ...
}: {
  options.cow.cat.enable = lib.mkEnableOption "Catppuccin theming everywhere";

  config = lib.mkIf config.cow.cat.enable {
    catppuccin = {
      autoEnable = true;
      enable = true;
      flavor = "mocha";
      accent = "green";
      cache.enable = true;
    };
  };
}
