{
  pkgs,
  inputs,
  ...
}: {
  nix = {
    channel.enable = false;
    registry.p.flake = inputs.self;
    package = pkgs.lix;
    settings = {
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

  system.switch = {
    enable = false;
    enableNg = true;
  };

  system.extraDependencies = with builtins; let
    flakeDeps = flake: [flake.outPath] ++ (foldl' (a: b: a ++ b) [] (map flakeDeps (attrValues flake.inputs or {})));
  in
    flakeDeps inputs.self;
}
