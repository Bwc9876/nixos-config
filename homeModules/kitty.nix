{
  config,
  lib,
  ...
}: {
  options.cow.kitty = {
    enable =
      lib.mkEnableOption "Kitty terminal emulator + customizations"
      // {
        default = config.cow.gdi.enable;
      };
  };

  config = lib.mkIf config.cow.kitty.enable {
    home.sessionVariables.TERMINAL = lib.getExe config.programs.kitty.package;
    programs.kitty = {
      enable = true;
      settings = {
        cursor_trail = 4;
        touch_scroll_multiplier = 4.0;
        visual_bell_duration = "0.5 ease-in linear";
        visual_bell_color = "#777777";
        enable_audio_bell = false;
        cursor_shape = "beam";
        background_opacity = 0.92;
        font_size = 12.0;
      };
    };
  };
}
