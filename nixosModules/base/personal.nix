{
  inputs,
  config,
  ...
}: {
  imports = [inputs.hm.nixosModules.default];

  time.timeZone = "America/New_York";

  users.users.bean = {
    isNormalUser = true;
    description = "Benjamin Crocker";
    autoSubUidGidRange = true;
    extraGroups = ["wheel"]; # For sudo
  };

  home-manager.users.root = {
    imports = [inputs.nix-index-db.homeModules.nix-index];
    home = {
      username = "root";
      homeDirectory = "/root";
      stateVersion = config.system.stateVersion;
    };
  };

  home-manager.users.bean = {
    imports = [inputs.nix-index-db.homeModules.nix-index];
    home = {
      username = "bean";
      homeDirectory = "/home/bean";
      file.".face".source = "${../../res/pictures/cow.png}";
      stateVersion = config.system.stateVersion;
    };
  };
}
