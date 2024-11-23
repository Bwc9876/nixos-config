{
  target = "x86_64-linux";
  extraOverlays = [];

  eval = {inputs, ...}: {
    description = "Framework 13 Laptop";

    edition = "25.05";

    includeBaseMods = true;

    roles = ["latest-linux" "dev" "graphics" "fun" "secureboot" "wireless" "hypervisor"];
    extraModules = [inputs.nixos-hardware.nixosModules.framework-13th-gen-intel];
  };
}
