{...}: let
  settings = {
    add_newline = false;
    character = {
      disabled = false;
      error_symbol = "[󰀨](bold red bg:crust)";
      format = "[ $symbol ](bg:crust)";
      success_symbol = "[󰗠](bold green bg:crust)";
    };
    cmd_duration = {
      disabled = false;
      format = "[ 󱎫 $duration ]($style)";
      min_time = 2000;
      style = "bg:crust blue";
    };
    directory = {
      format = "[ ($read_only )$path ]($style)";
      home_symbol = "󰋜";
      read_only = "󰌾";
      style = "bold green bg:crust";
      truncate_to_repo = true;
      truncation_length = 10;
    };
    format = "[░▒▓](crust)[ $os$hostname[](bg:crust #999999)$shell$username[](bg:crust #999999)$directory([](bg:crust #999999)$git_branch$git_commit$git_state)([](bg:crust #999999)$nodejs$python$rust$nix_shell)](bg:crust)[ ](crust)";
    git_branch = {
      format = "[ $symbol ($branch )]($style)";
      style = "bg:crust green";
      symbol = "󰘬";
    };
    git_state = {
      format = "\\([$state( $progress_current/$progress_total)]($style)\\)";
      merge = "󰘭";
      rebase = "󱗬";
      revert = "󰕍";
      style = "bg:crust green yellow";
    };
    git_status = {
      conflicted = "󰀦";
      format = "[$all_status $ahead_behind ]($style)";
      modified = "󰏫";
      style = "bg:crust green";
    };
    hostname = {
      format = "[$hostname( $ssh_symbol) ]($style)";
      ssh_only = false;
      ssh_symbol = "";
      style = "bold blue bg:crust";
    };
    line_break = {disabled = true;};
    nix_shell = {
      format = "[ $state ](bold blue bg:crust) ";
      impure_msg = "[󱄅 impure](bold red bg:crust)";
      pure_msg = "[󱄅](bold green bg:crust)";
      style = "bg:crust green";
      unknown_msg = "[󱄅 unknown](bold yellow bg:crust)";
    };
    nodejs = {
      format = "[ $symbol ($version) ]($style)";
      not_capable_style = "bg:crust green bold red";
      style = "bg:crust green";
      symbol = "󰎙";
    };
    os = {
      disabled = false;
      format = "[$symbol ]($style)";
      style = "bg:crust bold lightcrust";
      symbols = {
        Android = "";
        Debian = "";
        Linux = "";
        Macos = "";
        Manjaro = "";
        NixOS = "󱄅";
        Raspbian = "";
        Ubuntu = "";
        Windows = "";
      };
    };
    python = {
      format = "[ $symbol ($version) ]($style)";
      style = "bg:crust green";
      symbol = "󰌠";
    };
    right_format = "[ ](crust)\n($character$status[](bg:crust #999999))\n($cmd_duration[](bg:crust #999999))$time[▓▒░](crust)\n";
    rust = {
      format = "[ $symbol ($version) ]($style)";
      style = "bg:crust green";
      symbol = "󱘗";
    };
    shell = {
      bash_indicator = "󱆃";
      disabled = false;
      fish_indicator = "󰈺";
      format = "[ $indicator ]($style)";
      nu_indicator = "󰨊";
      powershell_indicator = "󰨊";
      style = "bg:crust blue";
      unknown_indicator = "󰋗";
    };
    status = {
      disabled = false;
      format = "[$status ]($style)";
      style = "bg:crust red";
    };
    time = {
      disabled = false;
      format = "[ $time ]($style)";
      style = "bg:crust bold blue";
      time_format = "%a %b %d %I:%M %p 󰥔";
      use_12hr = true;
    };
    username = {
      format = "[$user ]($style)";
      show_always = true;
      style_root = "bold red bg:crust";
      style_user = "blue bg:crust";
    };
  };
in {
  programs.starship = {
    enable = true;
    inherit settings;
  };

  home-manager.users.bean.programs.starship = {
    enable = true;
    inherit settings;
  };

  home-manager.users.root.programs.starship = {
    enable = true;
    inherit settings;
  };
}
