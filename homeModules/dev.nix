{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  options.cow.dev = {
    enable = lib.mkEnableOption "Dev stuff";
    c = lib.mkEnableOption "C/C++ dev stuff";
    rust = lib.mkEnableOption "Rust dev stuff";
    haskell = lib.mkEnableOption "Haskell dev stuff";
    web = lib.mkEnableOption "Web dev stuff";
    nix = (lib.mkEnableOption "Nix dev stuff") // {default = config.cow.dev.enable;};
    python = lib.mkEnableOption "Python dev stuff";
    dotnet = lib.mkEnableOption ".NET dev stuff";
    cutter = lib.mkEnableOption "Cutter";
    typst = lib.mkEnableOption "Typst";
    mc = lib.mkEnableOption "Minecraft modpack stuff";
    godot = lib.mkEnableOption "Game dev with Godot";
  };

  config = let
    conf = config.cow.dev;
  in
    lib.mkIf conf.enable {
      nixpkgs.overlays = lib.optional conf.rust inputs.fenix.overlays.default;

      xdg.configFile = {
        "astro/config.json" = lib.mkIf conf.web {
          text = builtins.toJSON {
            telemetry = {
              enabled = false;
              anonymousId = "";
              notifiedAt = "0";
            };
          };
        };
        "ghc/ghci.conf" = lib.mkIf conf.haskell {
          text = ''
            :set prompt "\ESC[1;35m\x03BB> \ESC[m"
            :set prompt-cont "\ESC[1;35m > \ESC[m"
          '';
        };
      };

      cow.imperm.keepCache =
        (lib.optional conf.rust ".cargo")
        ++ (lib.optionals conf.web [
          ".npm"
          ".pnpm"
        ]);

      cow.jj.enable = lib.mkDefault true;

      programs.git = {
        enable = true;
        settings = {
          init.defaultBranch = "main";
          advice.addIgnoredFiles = false;
        };
      };

      programs.npm = lib.mkIf conf.web {
        enable = true;
        package = pkgs.nodejs_latest;
        settings = {
          fund = false;
        };
      };

      programs.nix-your-shell = lib.mkIf conf.nix {
        enable = true;
      };

      home.packages = with pkgs;
        (lib.optionals (conf.rust or conf.c) [
          pkg-config
          gnumake
          gcc
          gdb
        ])
        ++ (lib.optionals conf.godot [
          godot
        ])
        ++ (lib.optionals conf.mc [
          jre
        ])
        ++ (lib.optionals conf.rust [
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
        ])
        ++ (lib.optionals conf.web [
          pnpm
          yarn
          # deno
        ])
        ++ (lib.optionals conf.haskell [
          haskell.compiler.ghc912
        ])
        ++ (lib.optionals conf.python [
          python3
          pipenv
          uv
          ruff
        ])
        ++ (lib.optionals conf.dotnet [
          dotnet-sdk_10
          dotnet-runtime_10
          mono
          dotnetPackages.Nuget
        ])
        ++ (lib.optionals conf.typst [
          typst
          typstyle
        ])
        ++ (lib.optional conf.cutter (cutter.withPlugins (p: with p; [rz-ghidra])));
    };
}
