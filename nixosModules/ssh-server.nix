{
  pkgs,
  lib,
  config,
  ...
}: {
  options.cow.ssh-server.enable = lib.mkEnableOption "OpenSSH daemon for accepting connections + customizations. Uses port 8069";

  config = lib.mkIf config.cow.ssh-server.enable {
    # For nicer term rendering
    environment.enableAllTerminfo = true;

    services.openssh = {
      enable = true;
      openFirewall = true;
      settings.Banner = let
        name = lib.toUpper config.networking.hostName;
        banner = pkgs.writeText "banner.txt" ''
          -= ${name} =-
        '';
      in "${banner}";
      listenAddresses = [
        {
          addr = "0.0.0.0";
        }
      ];
      # TODO: Maybe just use 22 like a normal person
      ports = [8069];
      settings.PasswordAuthentication = false;
      settings.UseDns = false;
      # settings.LogLevel = "DEBUG1";
      settings.PermitRootLogin = "prohibit-password";
      settings.KbdInteractiveAuthentication = false;
    };
  };
}
