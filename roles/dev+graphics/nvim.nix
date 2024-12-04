{pkg, ...}: {
  home-manager.users.bean = {
    wayland.windowManager.hyprland.settings.bind = [
      "SUPER,D,exec,neovide"
    ];
    programs = {
      nixvim = {
        clipboard.providers.wl-copy.enable = true;
      };
      neovide = {
        enable = true;
        settings = {
          fork = true;
          font = {
            normal = [];
            size = 18.0;
          };
          title-hidden = false;
        };
      };
    };
  };
}
