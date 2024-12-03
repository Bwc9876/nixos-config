#!/usr/bin/env nu

let paths = ls ~/.config/Code/User/workspaceStorage/*/workspace.json 
                    | get name 
                    | each {|it| open $it | get folder | str substring 7..};

let paths_display = $paths | each {|it| $it | str replace $"/home/($env.USER)" "󰋜 " | str replace "󰋜 /Documents/GitHub" "󰊤 "};

let res = $paths_display | str join "\n" | rofi -dmenu -i -p "VSCode" | complete;

if $res.exit_code == 1 {
    echo "Cancelled"
} else {
    let choice = $res.stdout | str trim;
    let idx = $paths_display | enumerate | where {|it| $it.item == $choice} | first | get index;
    let path = $paths | get $idx;
    echo $"Opening ($path)"
    code $path
}

