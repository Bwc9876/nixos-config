{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    github-desktop
    chromium
    google-lighthouse
    (cutter.withPlugins (p: with p; [rz-ghidra]))
  ];
}
