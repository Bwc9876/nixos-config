{...}: {
  pkgs,
  config,
  lib,
  ...
}: {
  options.cow.jj = {
    enable = lib.mkEnableOption "jj + customizations";
  };

  config = let
    conf = config.cow.jj;
  in (lib.mkIf conf.enable {
    programs.jujutsu = {
      enable = true;
      settings = {
        ui.pager = "less -FR";
      };
    };

    home.packages = with pkgs; [
      mergiraf
    ];
  });
}
