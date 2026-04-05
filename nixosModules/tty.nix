{
  config,
  lib,
  pkgs,
  ...
}: {
  options.cow.tty = {
    enable = lib.mkEnableOption "make TTY kmscon with optional auto-login";
    autoLogin = lib.mkEnableOption "autologin for bean if bean is enabled, else root";
  };

  config = lib.mkIf config.cow.tty.enable {
    services.getty.autologinUser = lib.mkIf config.cow.tty.autoLogin (
      lib.mkForce (
        if config.cow.bean.enable
        then "bean"
        else "root"
      )
    );

    services.kmscon = {
      enable = true;
      fonts = [
        {
          name = "Maple Mono";
          package = pkgs.maple-mono.NF-CN;
        }
      ];
    };
  };
}
