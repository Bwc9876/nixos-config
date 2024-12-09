#!/usr/bin/env nu

let dirs = zoxide query -l "" | lines

let menu = $dirs | each {|it| $"($it | split row "/" | last) <span color=\"#A2A2A2\"><i><small>\(($it | str replace $"/home/($env.USER)" "~")\)</small></i></span>" } | str join "\n"

let res = ($menu | rofi -dmenu -i -markup-rows -p "Zoxide" | complete)

if $res.exit_code == 1 {
    echo "Cancelled"
} else {
    let dir = $res.stdout | split row " <span color=\"#A2A2A2\"><i><small>(" | get 1 | split row ")</small>" | get 0
    kitty -d ($dir | str replace "~" $"/home/($env.USER)")
}
