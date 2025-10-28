{pkgs, ...}: {
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  environment.systemPackages = with pkgs; [flatpak-builder];
}
