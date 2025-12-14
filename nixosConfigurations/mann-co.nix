{
  lib,
  inputs,
  outputs,
  ...
}: {
  system = "aarch64-linux";

  modules =
    (builtins.attrValues (lib.filterAttrs (n: _: n != "base") outputs.nixosModules))
    ++ [
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      {disabledModules = ["${inputs.nixpkgs}/nixos/modules/profiles/base.nix"];}
      inputs.nixos-hardware.nixosModules.raspberry-pi-4
      (
        {pkgs, ...}: {
          nixpkgs.overlays = [
            (final: super: {
              makeModulesClosure = x: super.makeModulesClosure (x // {allowMissing = true;});
            })
          ];

          system.stateVersion = "25.05";
          networking.hostName = "mann-co";

          security.sudo.wheelNeedsPassword = false;

          cow = {
            bean = {
              enable = true;
              sudoer = true;
            };
            network.enable = true;
            ssh-server.enable = true;
          };
        }
      )
    ];
}
