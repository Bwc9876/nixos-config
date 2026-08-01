{
  config,
  lib,
  ...
}: {
  options.cow.alacritty = {
    enable =
      lib.mkEnableOption "Alacritty terminal emulator + customizations"
      // {
        default = config.cow.gdi.enable;
      };
  };

  config = lib.mkIf config.cow.alacritty.enable {
    home.sessionVariables.TERMINAL = lib.getExe config.programs.alacritty.package;
    programs.alacritty = {
      enable = true;
      settings = {
        window.opacity = 0.92;
        bell = {
          duration = 500;
          animation = "Ease";
          color = "#777777";
        };
        cursor.style = {
          shape = "Beam";
          blinking = "On";
        };
        font.size = 12.0;
      };
    };
  };
}
