{
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
      fish =
        (lib.mkEnableOption "Fish Completions In Nushell")
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
          fishComplete = builtins.replaceStrings ["__fish__"] ["${pkgs.fish}/bin/fish"] (
            lib.fileContents ../res/nushellCompletions/fish.nu
          );
          carapaceComplete = builtins.replaceStrings ["__carapace__"] ["${pkgs.carapace}/bin/carapace"] (
            lib.fileContents ../res/nushellCompletions/carapace.nu
          );
          completions = ''
            {|spans|
                # if the current command is an alias, get it's expansion
                let expanded_alias = (scope aliases | where name == $spans.0 | get -o 0 | get -o expansion)

                # overwrite

                let spans = (if $expanded_alias != null  {
                    # put the first word of the expanded alias first in the span
                    $spans | skip 1 | prepend ($expanded_alias | split row " ")
                } else { $spans })

                match $spans.0 {
                  ${lib.optional conf.completers.fish ''
              nu => ${fishComplete}
              git => ${fishComplete}
            ''}
                  _ => ${
              if conf.completers.carapace
              then carapaceComplete
              else if conf.completers.fish
              then fishComplete
              else "{|spans| []}"
            }
                } | do $in $spans
            }
          '';
          cnf = lib.fileContents ../res/command_not_found.nu;
          nu_config = let
            doCompletions = builtins.any (x: x) (builtins.attrValues conf.completers);
          in ''
            {
              show_banner: false,
              completions: {
                external: {
                  enable: ${doCompletions}
                  completer: ${
              if doCompletions
              then completions
              else "{|spans| []}"
            }
                },
              },
              hooks: {
              ${lib.optional conf.commandNotFound ''
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
          configFile = ''
            $env.config = ${nu_config}

            ${lib.optional config.cow.starship.enable ''
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
