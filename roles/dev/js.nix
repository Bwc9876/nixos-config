{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nodejs
    nodePackages.pnpm
    yarn
    deno
  ];
}
