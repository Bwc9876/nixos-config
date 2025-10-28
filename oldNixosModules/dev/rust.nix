{
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.overlays = [
    inputs.fenix.overlays.default
  ];

  environment.systemPackages = with pkgs; [
    (pkgs.fenix.complete.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
    ])
    rust-analyzer-nightly
    cargo-tauri
    mprocs
    evcxr
  ];
}
