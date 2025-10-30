{inputs, ...}: {
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [inputs.nix-index-db.homeModules.nix-index];

  options.cow.comma.enable = lib.mkEnableOption "Comma With DB";

  config = lib.mkIf config.cow.comma.enable {
    nixpkgs.overlays = [inputs.nix-index-db.overlays.nix-index];
    programs.nix-index.enable = true;
    home.packages = with pkgs; [
      comma-with-db
    ];
  };
}
