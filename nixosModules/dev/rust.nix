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

  # Use mold for linking Rust code
  # home-manager.users.bean.home.file.".cargo/config.toml".text = ''
  #   [target.x86_64-unknown-linux-gnu]
  #   linker = "${pkgs.clang}/bin/clang"
  #   rustflags = [
  #     "-C", "link-arg=--ld-path=${pkgs.mold}/bin/mold",
  #   ]
  # '';
}
