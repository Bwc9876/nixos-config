{...}: {
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
      {
        name = "FHG_IMC_Color";
        description = "FHG IMC Color";
        deviceUri = "https://wcuprintp01.wcupa.net:9164/printers/FHG_IMC_Color";
        model = "drv:///sample.drv/generic.ppd";
      }
    ];
  };
}
