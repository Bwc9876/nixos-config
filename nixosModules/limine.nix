{
  config,
  lib,
  ...
}: {
  options.cow.limine = {
    enable = lib.mkEnableOption "limine bootloader and bind mount for keys";
    microsoft = lib.mkEnableOption "Microsoft SecureBoot certs";
  };

  config = lib.mkIf config.cow.limine.enable {
    cow.imperm.keep = ["/var/lib/sbctl"];

    boot.loader.limine = {
      enable = true;
      secureBoot = {
        enable = true;
        autoGenerateKeys = true;
        autoEnrollKeys = {
          enable = true;
          extraArgs = ["--firmware-builtin"] ++ (lib.optional config.cow.limine.microsoft "--microsoft");
        };
      };
      style = {
        wallpapers = [../res/pictures/background.png];
        backdrop = "1E1E2E";
        interface = {
          branding = "Mooooo~ :3";
          brandingColor = "A6E3A1";
          helpColor = "89B4FA";
          helpColorBright = "89DCEB";
        };
      };
    };
  };
}
