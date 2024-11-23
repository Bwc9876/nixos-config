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
}
