{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    hyfetch
    fastfetch
    lolcat
    cowsay
    kittysay
    toilet
    gay
    pipes-rs
  ];

  home-manager.users.bean.programs.nushell.shellAliases = {
    screensaver = "pipes-rs -k curved -p 10 --fps 30";
    neofetch = "hyfetch";
  };

  home-manager.users.bean.programs.hyfetch = {
    enable = true;
    settings = {
      backend = "fastfetch";
      color_align = {
        custom_colors = [];
        fore_back = null;
        mode = "horizontal";
      };
      distro = null;
      light_dark = "dark";
      lightness = 0.65;
      mode = "rgb";
      preset = "interprogress";
      pride_month_disable = false;
      pride_month_shown = [];
    };
  };
}
