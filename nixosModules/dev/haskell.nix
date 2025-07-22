{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    haskell.compiler.ghc912
  ];

  home-manager.users.bean.xdg.configFile."ghc/ghci.conf".text = ''
    :set prompt "\ESC[1;35m\x03BB> \ESC[m"
    :set prompt-cont "\ESC[1;35m > \ESC[m"
  '';
}
