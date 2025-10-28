{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    xcowsay
    tuxpaint
  ];

  home-manager.users.bean.home.file."tuxpaintrc".text = ''
    fullscreen=native
    startblank=yes
    autosave=yes
  '';
}
