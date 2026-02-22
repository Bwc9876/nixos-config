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
        ui = {
          default-command = [
            "log"
            "--reversed"
            "-n"
            "15"
          ];
          pager = "less -FR";
          editor = lib.mkIf config.cow.neovim.enable "nvim";
          diff-editor = ":builtin";
          merge-editor = "mergiraf";
        };
        git = {
          private-commits = "description('private:*')";
        };

        template-aliases = {
          "format_short_id(id)" = "id.shortest()";
          "format_timestamp(timestamp)" = "timestamp.ago()";
        };
        aliases = {
          "push" = [
            "git"
            "push"
          ];
          "pull" = [
            "git"
            "fetch"
          ];
          "bsm" = [
            "bookmark"
            "set"
            "main"
          ];
          "bm" = ["bookmark"];
          "d" = [
            "describe"
            "-m"
          ];
          "s" = ["show -s"];
          "ss" = ["show"];
          "n" = ["new"];
          "ed" = ["edit"];
        };
      };
    };

    home.packages = with pkgs; [
      less
      mergiraf
    ];
  });
}
