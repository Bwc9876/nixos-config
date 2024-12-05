{
  pkgs,
  inputs,
  lib,
  ...
}: let
  init-starship = pkgs.runCommand "starship-init" {} ''
    ${pkgs.starship}/bin/starship init nu > $out
  '';
in rec {
  home-manager.users.bean.programs.nushell = with lib; {
    enable = true;
    shellAliases = {
      cd = "z";
      sw = "zi";
      py = "python";
      cat = "bat";
      pcat = "prettybat";
      pbat = "prettybat";
      dog = "doggo";
      man = "__batman";
      bgrep = "batgrep";
    };
    configFile.text = ''
      let fish_completer = {|spans|
          ${pkgs.fish}/bin/fish --command $'complete "--do-complete=($spans | str join " ")"'
          | $"value(char tab)description(char newline)" + $in
          | from tsv --flexible --no-infer
      }
      let zoxide_completer = {|spans|
          let query = $spans | skip 1
          let z_results = $query | zoxide query -l ...$in | lines | where {|x| $x != $env.PWD}
          let l_results = ls -a | where type != "file" | where (($it.name | str downcase) | str starts-with ($query | get 0 | str downcase)) | get name
          $l_results | append $z_results
      }
      let multiple_completers = {|spans|
          # if the current command is an alias, get it's expansion
          let expanded_alias = (scope aliases | where name == $spans.0 | get -i 0 | get -i expansion)

          # overwrite

          let spans = (if $expanded_alias != null  {
              # put the first word of the expanded alias first in the span
              $spans | skip 1 | prepend ($expanded_alias | split row " ")
          } else { $spans })

          match $spans.0 {
              z => $zoxide_completer
              zi => $zoxide_completer
              __zoxide_z => $zoxide_completer
              __zoxide_zi => $zoxide_completer
              _ => $fish_completer
          } | do $in $spans
      }

      let command_not_found = ${fileContents "${inputs.self}/res/command_not_found.nu"}

      def --env __batman [...rest:string] {
        BAT_THEME="Monokai Extended" batman ...$rest
      }

      $env.config = {
          show_banner: false
          completions: {
              external: {
                  enable: true
                  completer: $multiple_completers
              }
          }
          hooks: {
              command_not_found: $command_not_found
          }
      }

      source ${init-starship}

      plugin add ${pkgs.callPackage "${inputs.self}/pkgs/nu_plugin_dbus.nix" {}}/bin/nu_plugin_dbus

    '';
  };
  home-manager.users.root.programs.nushell = with home-manager.users.bean.programs.nushell; {
    enable = true;
    inherit configFile shellAliases;
  };
}
