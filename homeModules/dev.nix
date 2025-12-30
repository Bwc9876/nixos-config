{inputs, outputs, ...}: {
  config,
  lib,
  pkgs,
  ...
}: {
  options.cow.dev = let
    mkLangOpt = d: ((lib.mkEnableOption d) // {default = config.cow.dev.enable;});
  in {
    enable = lib.mkEnableOption "Dev stuff (all on by default)";
    c = mkLangOpt "C/C++ dev stuff";
    rust = mkLangOpt "Rust dev stuff";
    haskell = mkLangOpt "Haskell dev stuff";
    web = mkLangOpt "Web dev stuff";
    nix = mkLangOpt "Nix dev stuff";
    python = mkLangOpt "Python dev stuff";
    dotnet = mkLangOpt ".NET dev stuff";
    cutter = mkLangOpt "Cutter";
		mc = lib.mkEnableOption "Minecraft modpack stuff";
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
        [
          ".config/gh"
        ]
        ++ (lib.optional conf.rust ".cargo")
        ++ (lib.optionals conf.web [
          ".npm"
          ".pnpm"
        ]);

      programs.git = {
        enable = true;
        settings = {
          init.defaultBranch = "main";
          advice.addIgnoredFiles = false;
        };
      };

      home.packages = with pkgs;
        [gh]
        ++ (lib.optionals (conf.rust or conf.c) [
          pkg-config
          gnumake
          gcc
          gdb
        ])
				++ (lib.optionals conf.mc [
					outputs.packages.${pkgs.system}.packwiz
					inputs.spoon.packages.${pkgs.system}.mc-srv-git-hook.passthru.mrpack-install'
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
          nodejs_latest
          nodePackages.pnpm
          yarn
          deno
        ])
        ++ (lib.optionals conf.haskell [
          haskell.compiler.ghc912
        ])
        ++ (lib.optionals conf.python [
          python3
          poetry
          pipenv
          uv
          ruff
          black
        ])
        ++ (lib.optionals conf.dotnet [
          dotnet-sdk
          dotnet-runtime
          mono
          dotnetPackages.Nuget
        ])
        ++ (lib.optional conf.cutter (cutter.withPlugins (p: with p; [rz-ghidra])));
    };
}
