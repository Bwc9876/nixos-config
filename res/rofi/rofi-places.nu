#!/usr/bin/env nu

let contents = open ~/.local/share/user-places.xbel

let hash = $contents | hash md5 

let cache = ['~' '.cache' 'rofi-places' $hash] | path join | path expand
let dataPath = [$cache "data.nuon"] | path join

let display_loc = {|it| (if ($it | str starts-with "file://") { $it | str substring 7.. } else { $it } | str replace $"/home/($env.USER)" "~")}

let places = if ($dataPath | path exists) {
    open $dataPath
} else {
    let places = $contents | lines | skip 2 | str join "\n" | from xml | get content | where tag == "bookmark" | where attributes.href != "" | each {|it| {loc: $it.attributes.href, disp_loc: ($it.attributes.href | each $display_loc), name: ($it.content | where tag == "title" | get content.0.content.0), icon: ($it.content | where tag == "info" | get content.0.content.0 | where tag == "icon" | get attributes.name.0 )} }
    mkdir $cache
    $places | to nuon | save $dataPath
    $places
}

let menu = $places | each {|it| $"($it.name) <span color=\"#A2A2A2\"><i><small>\(($it.disp_loc)\)</small></i></span> \u{0}icon\u{1f}($it.icon)" } | str join "\n"

let res = ($menu | rofi -dmenu -i -markup-rows -show-icons -p "Dolphin" | complete) 

if $res.exit_code == 1 {
    echo "Cancelled"
} else {
    let name = $res.stdout | split row " <span color=\"#A2A2A2\">" | get 0
    let loc = $places | where name == $name | get 0.loc
    echo $"Opening ($loc)"
    dolphin --new-window $loc
}
