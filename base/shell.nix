{pkgs, ...}: {
  users.users.bean.shell = pkgs.nushell;
  users.users.root.shell = pkgs.nushell;
  programs.fish.enable = true;
  documentation.man.generateCaches = false;
  programs.ssh.startAgent = true;

  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';

  environment = {
    shells = with pkgs; [nushell fish];
    variables.EDITOR = "nvim";

    systemPackages = with pkgs; [
      nushell
      file
      screen
      util-linux
      inetutils
      just
      man-pages
      htop
      dig
      doggo
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
      # Broken
      extraPackages = with pkgs.bat-extras; [batman batgrep batwatch];
    };
  };

  home-manager.users.root.programs = {
    zoxide.enable = true;
    ripgrep.enable = true;
    command-not-found.enable = false;
    bat.enable = true;
    nix-index.enable = true;
  };
}
