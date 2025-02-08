{...}: {
  nix.settings = {
    substituters = [
      "http://black-mesa:5000"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "black-mesa:tAX++uOKyqP70gnwx5zHBMiZ0kee8WberjlPZmDuyxw="
    ];
  };
}
