{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.nix-index-db.homeModules.nix-index];

  options.cow.comma.enable = lib.mkEnableOption "Command With DB";

  config = lib.mkIf config.cow.comma.enable {
    nix-index.enable = true;
    home.packages = with pkgs; [
      comma-with-db
    ];
  };
}
