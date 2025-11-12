#!/usr/bin/env nu

let date_format = "%Y-%m-%d_%H-%M-%S"

let captures_folder = $"($env.HOME)/Videos/Captures"

if not ($captures_folder | path exists) {
    mkdir $captures_folder
}

let out_name = date now | format date $"($captures_folder)/($date_format).mp4"

let stat = do { slurp -d } | complete

if $stat.exit_code == 1 {
    echo "No selection made"
    exit
}

wf-recorder -g ($stat.stdout) -F fps=30 -f $out_name

let action = notify-send --app-name=simplescreenrecorder --icon=simplescreenrecorder -t 7500 --action=open=Open --action=delete=Delete "Recording finished" $"File saved to ($out_name)"

match $action {
    "open" => {
        xdg-open $out_name
    }
    "delete" => {
        rm $out_name
    }
}
