{
  inputs,
  outputs,
  ...
}: {
  system = "aarch64-linux";

  modules = [
    (outputs.lib.applyRoles ["base" "ssh"])
    {
      system.stateVersion = "25.05";
      networking.hostName = "mann-co";
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
}
