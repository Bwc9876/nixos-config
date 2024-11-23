#!/usr/bin/env nu

let file_path = grimblast --freeze copysave area

if $file_path == "" {
    exit 1;
}

let choice = notify-send --app-name=screengrab -i $file_path -t 7500 --action=open=Open --action=folder="Show In Folder" --action=edit=Edit --action=delete=Delete "Screenshot taken" $"Screenshot saved to ($file_path) and copied to clipboard"

match $choice {
    "open" => {
        xdg-open $file_path
    }
    "folder" => {
        xdg-open ($file_path | path dirname)
    }
    "edit" => {
        swappy -f $file_path
    }
    "delete" => {
        rm $file_path
    }
}
