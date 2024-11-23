{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    python3
    python311Packages.django
    poetry
    pipenv
    black
  ];
}
