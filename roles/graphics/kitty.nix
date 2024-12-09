{...}: {
  home-manager.users.bean.programs.kitty = {
    enable = true;
    font = {
      name = "monospace";
      size = 18;
    };
    keybindings = {
      "ctrl+shift+o" = "open_url_with_hints";
    };
    settings = {
      cursor_shape = "beam";
      background_opacity = 0.92;
    };
  };
}
