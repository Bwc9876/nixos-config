{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    github-desktop
  ];
}
