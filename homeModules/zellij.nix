{
  lib,
  config,
  ...
}: {
  options.cow.zellij = {
    enable = (lib.mkEnableOption "zellij + customizations") // {default = config.cow.dev.enable;};
  };

  config = let
    conf = config.cow.zellij;
  in
    lib.mkIf conf.enable {
      programs.zellij = {
        enable = true;
        settings = {
          show_startup_tips = false;
          show_release_notes = false;
          osc8_hyperlinks = true;
        };
      };
    };
}
