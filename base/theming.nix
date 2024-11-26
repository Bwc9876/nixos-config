{inputs, ...}: let
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "green";
  };
in {
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
  ];

  inherit catppuccin;

  home-manager.users.bean = {
    imports = [
      inputs.catppuccin.homeManagerModules.catppuccin
    ];

    inherit catppuccin;
  };
}
