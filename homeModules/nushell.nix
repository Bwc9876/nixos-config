{...}: {
  config,
  pkgs,
  lib,
  ...
}: {
  options.cow.nushell = {
    enable = lib.mkEnableOption "Nushell + Customizations";
    commandNotFound = lib.mkEnableOption "Custom Nix Command Not Found for Nushell";
    completers = {
      carapace =
        (lib.mkEnableOption "Carapace Completer In Nushell")
        // {
          default = true;
        };
    };
  };

  config = let
    conf = config.cow.nushell;
  in
    lib.mkIf conf.enable {
      cow.imperm.keep = [".local/share/zoxide"];
      cow.imperm.keepFiles = [".config/nushell/history.txt"];

      programs = {
        zoxide.enable = true;
        command-not-found.enable = !conf.commandNotFound;
        nushell = let
          carapaceComplete = builtins.replaceStrings ["__carapace__"] ["${pkgs.carapace}/bin/carapace"] (
            lib.fileContents ../res/nushellCompletions/carapace.nu
          );
          cnf = lib.fileContents ../res/command_not_found.nu;
          nu_config = let
            doCompletions = builtins.any (x: x) (builtins.attrValues conf.completers);
          in ''
            {
              show_banner: false,
              completions: {
                external: {
                  enable: ${builtins.toJSON doCompletions}
                  completer: ${
              if doCompletions
              then carapaceComplete
              else ''{|spans| []}''
            }
                },
              },
              hooks: {
                ${lib.optionalString conf.commandNotFound ''
              command_not_found: ${cnf}
            ''}
              }
            }
          '';
          init-starship = pkgs.runCommand "starship-init" {} ''
            ${pkgs.starship}/bin/starship init nu > $out
          '';
        in {
          enable = true;
          configFile.text = ''
            $env.config = ${nu_config}

            # Utility Cmds
            def --wrapped dev [...rest] { nix develop -c env SHELL=nu ...$rest }
            def --wrapped devsh [ ...rest ] { dev nu ...$rest }
            def --wrapped dvim [...rest] { dev vim ...$rest }

            ${lib.optionalString config.cow.starship.enable ''
              source ${init-starship}
            ''}
          '';
          shellAliases = {
            "cd" = "z";
            "py" = "python";
            "🥺" = "sudo";
          };
        };
      };
    };
}
