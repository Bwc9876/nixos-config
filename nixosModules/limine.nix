{
  config,
  lib,
  ...
}: {
  options.cow.limine = {
    enable = lib.mkEnableOption "limine bootloader and bind mount for keys";
  };

  config = lib.mkIf config.cow.limine.enable {
    cow.imperm.keep = ["/var/lib/sbctl"];

    boot.loader.limine = {
      enable = true;
      secureBoot.enable = true;
    };
  };
}
