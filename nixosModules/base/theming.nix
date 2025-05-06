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
      inputs.catppuccin.homeModules.catppuccin
    ];

    catppuccin =
      {
        mako.enable = false;
      }
      // catppuccin;
  };

  home-manager.users.root = {
    imports = [
      inputs.catppuccin.homeModules.catppuccin
    ];

    catppuccin =
      {
        mako.enable = false;
      }
      // catppuccin;
  };
}
