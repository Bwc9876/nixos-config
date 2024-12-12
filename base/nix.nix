{
  pkgs,
  inputs,
  lib,
  ...
}: {
  nix = {
    channel.enable = false;
    registry.p.flake = inputs.self;
    package = pkgs.lix;
    settings = {
      # So we can do `import <nixpkgs>`
      nix-path = "nixpkgs=${inputs.nixpkgs}";
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
    };
  };

  # Switch ng is not as weird
  system.switch = {
    enable = false;
    enableNg = true;
  };

  # Kill nix daemon builds over user sessions
  systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = lib.mkDefault 250;

  # Keeps flake inputs when GCing
  system.extraDependencies = with builtins; let
    flakeDeps = flake: [flake.outPath] ++ (foldl' (a: b: a ++ b) [] (map flakeDeps (attrValues flake.inputs or {})));
  in
    flakeDeps inputs.self;
}
