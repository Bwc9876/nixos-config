{
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.overlays = [
    inputs.rust-overlay.overlays.default
  ];

  environment.systemPackages = with pkgs; [
    (rust-bin.selectLatestNightlyWith (toolchain:
      toolchain.default.override {
        targets = ["wasm32-unknown-unknown"];
      }))
    cargo-tauri
    mprocs
    evcxr
  ];
}
