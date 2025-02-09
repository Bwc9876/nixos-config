{pkgs, ...}: {
  packages = with pkgs; [
    alejandra
    shfmt
  ];
}
