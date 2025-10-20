{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    google-lighthouse
    (cutter.withPlugins (p: with p; [rz-ghidra]))
  ];
}
