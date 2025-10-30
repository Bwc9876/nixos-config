{inputs, ...}: {
  config,
  lib,
  pkgs,
  ...
}: {
  options.cow.dev = let
    mkLangOpt = d: ((lib.mkEnableOption d) // {default = true;});
  in {
    enable = lib.mkEnableOption "Dev stuff (all on by default)";
    c = mkLangOpt "C/C++ dev stuf";
    rust = mkLangOpt "Rust dev stuff";
    haskell = mkLangOpt "Haskell dev stuff";
    js = mkLangOpt "JavaScript dev stuff";
    nix = mkLangOpt "Nix dev stuff";
    python = mkLangOpt "Python dev stuff";
    dotnet = mkLangOpt ".NET dev stuff";
  };

  config = let
    conf = config.cow.dev;
  in
    lib.mkIf conf.enable {
      nixpkgs.overlays = lib.optional conf.rust inputs.fenix.overlays.default;

      xdg.configFile = {
        "astro/config.json" = lib.mkIf conf.js {
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
        ++ (lib.optionals conf.js [
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
        ++ (lib.optionals conf.js [
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
        ]);
    };
}
