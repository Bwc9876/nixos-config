{
  target = "aarch64-linux";

  eval = {inputs, ...}: {
    description = "Raspberry Pi 4 Model B";
    edition = "25.05";

    includeBaseMods = true;

    roles = ["ssh"];
    extraModules = [
      {
        nixpkgs.overlays = [
          (final: super: {
            makeModulesClosure = x:
              super.makeModulesClosure (x // {allowMissing = true;});
          })
        ];
      }
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      {disabledModules = ["${inputs.nixpkgs}/nixos/modules/profiles/base.nix"];}
      inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ];
  };
}
