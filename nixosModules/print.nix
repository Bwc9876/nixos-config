{...}: {
  config,
  lib,
  ...
}: {
  options.cow.print.enable = lib.mkEnableOption "stateless printing + WCU printers";

  config = lib.mkIf config.cow.print.enable {
    services.printing = {
      enable = true;
      stateless = true;
    };

    hardware.printers = {
      ensurePrinters = [
        {
          name = "RamPrint";
          description = "WCU RamPrint";
          deviceUri = "https://wcuprintp01.wcupa.net:9164/printers/RamPrint";
          model = "drv:///sample.drv/generic.ppd";
        }
      ];
    };
  };
}
