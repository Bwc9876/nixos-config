#!/usr/bin/env nu

const SILENCED_APP_NAMES = [
    "vesktop",
    "discord",
    "thunderbird",
    "newsboat"
]

const APP_SOUNDS = {
    "simplescreenrecorder": "camera-click",
    "screengrab": "camera-click",
    "battery-notif": "critical",
    "kde connect": "pixel-notif",
    "DEFAULT": "notif",
}

let name = $env.SWAYNC_APP_NAME? | default "" | str downcase

# let LOG_FILE = $"($env.HOME)/.sawync-app-log.txt";

# let log = if ($LOG_FILE | path exists) {
#     (open $LOG_FILE) | lines
# } else {
#     []
# };

# $log | append $name | str join "\n" | save -f $LOG_FILE

def main [sounds_path: string] {
    let dnd = swaync-client -D | from json;
    if (not $dnd) and ($name not-in $SILENCED_APP_NAMES) {
        let sound = $APP_SOUNDS | get -i $name | default $APP_SOUNDS.DEFAULT;
        aplay $"($sounds_path)/($sound).wav"
    }
}
