#!/usr/bin/env nu

let icons = {
    "charging": [
        "󰢜",
        "󰂆",
        "󰂇",
        "󰂈",
        "󰢝",
        "󰂉",
        "󰢞",
        "󰂊",
        "󰂋",
        "󰂅"
    ],
    "default": [
        "󰁺",
        "󰁻",
        "󰁼",
        "󰁽",
        "󰁾",
        "󰁿",
        "󰂀",
        "󰂁",
        "󰂂",
        "󰁹"
    ]
}

let percent = open /sys/class/power_supply/BAT1/capacity | into int

let status = open /sys/class/power_supply/BAT1/status | str trim

let idx = if $percent == 100 {
    9
} else {
    ($percent / 10) | into int
}

let icon = if $status == "Charging" or $status == "Full" {
    ($icons | get "charging" | get $idx) + " "
} else {
    $icons | get "default" | get $idx
}

echo $"($icon) ($percent)󰏰"
