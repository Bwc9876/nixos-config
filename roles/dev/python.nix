{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    python3
    poetry
    pipenv
    black
  ];
}
