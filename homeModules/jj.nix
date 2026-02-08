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
        ui.default-command = "log";
        ui.pager = "less -FR";
        aliases = {
          "push" = ["git" "push"];
          "pull" = ["git" "fetch"];
          "bsm" = ["bookmark" "set" "main"];
          "bm" = ["bookmark"];
          "d" = ["describe" "-m"];
          "s" = ["show -s"];
          "ss" = ["show"];
          "n" = ["new"];
          "ed" = ["edit"];
        };
      };
    };

    home.packages = with pkgs; [
      mergiraf
    ];
  });
}
