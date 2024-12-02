{
  pkgs,
  lib,
  ...
}: {
  users.users.bean.shell = pkgs.nushell;
  users.users.root.shell = pkgs.nushell;
  programs.fish.enable = true;
  documentation.man.generateCaches = false;
  programs.ssh.startAgent = true;
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
      htop
    ];
  };

  programs.git.enable = true;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  home-manager.users.bean.programs = {
    command-not-found.enable = false;
    nix-index.enable = true;
    zoxide.enable = true;
    ripgrep.enable = true;
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [prettybat batman batgrep batwatch];
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      catppuccin.enable = false;
    };
  };
}
