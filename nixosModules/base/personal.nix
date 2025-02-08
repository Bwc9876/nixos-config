{
  edition,
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
    extraGroups = ["libvirtd" "networkmanager" "wheel" "video" "lpadmin" "wireshark"]; # TODO: Break up groups across files?
  };

  home-manager.users.root = {
    imports = [inputs.nix-index-db.hmModules.nix-index];
    home = {
      username = "root";
      homeDirectory = "/root";
      stateVersion = config.system.stateVersion;
    };
  };

  home-manager.users.bean = {
    imports = [inputs.nix-index-db.hmModules.nix-index];
    home = {
      username = "bean";
      homeDirectory = "/home/bean";
      file.".face".source = "${inputs.self}/res/pictures/cow.png";
      stateVersion = config.system.stateVersion;
    };
  };
}
