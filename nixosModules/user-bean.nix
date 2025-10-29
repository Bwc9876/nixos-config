{config, lib, outputs, ...}: {
  options.cow.bean = {
    enable = lib.mkEnableOption "Bean user";
    sudoer = lib.mkEnableOption "Bean being a sudoer";
  };

  config = lib.mkIf config.cow.bean.enable {
    users.users.bean = {
      isNormalUser = true;
      description = "Ben C";
      extraGroups = lib.optional config.cow.bean.sudoer ["wheel"]; 
    }; 

    home-manager.users.bean = lib.mkIf config.cow.hm.enable {
      imports = builtins.attrValues outputs.homeModules; 
      cow.bean.enable = true;
      cow.gdi.enable = config.cow.gdi.enable;
      home.stateVersion = "25.05";
    };
  };
}
