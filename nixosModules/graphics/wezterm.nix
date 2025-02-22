{...}: {
  home-manager.users.bean.programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        font = wezterm.font("monospace"),
        font_size = 18.0,
        color_scheme = "Catppuccin Mocha",
        enable_tab_bar = false,
        window_background_opacity = 0.92,
        default_cursor_style = "SteadyBar",
        cursor_thickness = 2,
        keys = {
          {key="o", mods="CTRL|SHIFT", action="OpenLinkAtMouseCursor"}
        }
      }
    '';
  };
}
