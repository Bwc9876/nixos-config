{outputs, ...}: {
  system = "x86_64-linux";
  modules = [
    {
      system.stateVersion = "25.05";
      networking.hostName = "test";
    }
    (outputs.lib.applyRoles ["base" "latest-linux" "normalboot" "vm"])
  ];
}
