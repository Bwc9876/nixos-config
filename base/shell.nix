{
  pkgs,
  lib,
  ...
}: {
  users.users.bean.shell = pkgs.nushell;
  programs.fish.enable = true;
  documentation.man.generateCaches = false;
  environment = {
    shells = with pkgs; [nushell fish];
    variables.EDITOR = "nvim";

    systemPackages = with pkgs; [
      nushell
      comma-with-db
      file
      screen
      util-linux
      inetutils
      just
      nix-output-monitor
      man-pages
    ];
  };

  programs.starship = {
    enable = true;
    settings = fromTOML (lib.fileContents ../res/starship.toml);
  };

  programs.git.enable = true;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  home-manager.users.bean = {
    programs = {
      command-not-found.enable = false;
      nix-index.enable = true;
      zoxide.enable = true;
      ripgrep.enable = true;
      bat = {
        enable = true;
        config = {
          theme = "OneHalfDark";
        };
        extraPackages = with pkgs.bat-extras; [prettybat batman batgrep batwatch];
      };
      starship = {
        enable = true;
        settings = fromTOML (lib.fileContents ../res/starship.toml);
      };
      neovim = {
        enable = true;
        defaultEditor = true;
        plugins = with pkgs; [
          vimPlugins.transparent-nvim
        ];
      };
    };
  };
}
