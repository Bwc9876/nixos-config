#!/usr/bin/env nu

# const WMO_CODE = {
#     0: "Sunny",
#     1: "PartlyCloudy",
#     2: "Cloudy",
#     3: "VeryCloudy",
    
# }

def match_wmo_code [code: int] {
    match $code {
        0 => "Sunny",
        1 => "PartlyCloudy",
        2 => "Cloudy",
        3 => "VeryCloudy",
        45 | 48 => "Fog",
        51 | 53 | 61 | 63 => "LightRain",
        55 | 65 => "HeavyRain"
        56 | 66 => "LightSleet",
        57 | 67 => "HeavySleet",
        71 | 73 | 77 => "LightSnow",
        75 => "HeavySnow",
        80 | 81 => "LightShowers",
        82 => "HeavyShowers",
        85 => "LightSnowShowers",
        86 => "HeavySnowShowers",
        95 | 96 | 99 => "ThunderyShowers",
        _ => "Unknown"
    }
}

const WWO_CODE = {
    "113": "Sunny",
    "116": "PartlyCloudy",
    "119": "Cloudy",
    "122": "VeryCloudy",
    "143": "Fog",
    "176": "LightShowers",
    "179": "LightSleetShowers",
    "182": "LightSleet",
    "185": "LightSleet",
    "200": "ThunderyShowers",
    "227": "LightSnow",
    "230": "HeavySnow",
    "248": "Fog",
    "260": "Fog",
    "263": "LightShowers",
    "266": "LightRain",
    "281": "LightSleet",
    "284": "LightSleet",
    "293": "LightRain",
    "296": "LightRain",
    "299": "HeavyShowers",
    "302": "HeavyRain",
    "305": "HeavyShowers",
    "308": "HeavyRain",
    "311": "LightSleet",
    "314": "LightSleet",
    "317": "LightSleet",
    "320": "LightSnow",
    "323": "LightSnowShowers",
    "326": "LightSnowShowers",
    "329": "HeavySnow",
    "332": "HeavySnow",
    "335": "HeavySnowShowers",
    "338": "HeavySnow",
    "350": "LightSleet",
    "353": "LightShowers",
    "356": "HeavyShowers",
    "359": "HeavyRain",
    "362": "LightSleetShowers",
    "365": "LightSleetShowers",
    "368": "LightSnowShowers",
    "371": "HeavySnowShowers",
    "374": "LightSleetShowers",
    "377": "LightSleet",
    "386": "ThunderyShowers",
    "389": "ThunderyHeavyRain",
    "392": "ThunderySnowShowers",
    "395": "HeavySnowShowers",
}

const WEATHER_ICONS = {
    "Unknown": "󰨹",
    "Cloudy": "󰖐",
    "Fog": "󰖑",
    "HeavyRain": "󰖖",
    "HeavyShowers": "󰖖",
    "HeavySnow": "󰼶",
    "HeavySnowShowers": "󰙿",
    "LightRain": "󰖗",
    "LightShowers": "󰖗",
    "LightSleet": "󰖒",
    "LightSleetShowers": "󰖒",
    "LightSnow": "󰖘",
    "LightSnowShowers": "󰖘",
    "PartlyCloudy": "󰖕",
    "Sunny": "󰖙",
    "ThunderyHeavyRain": "󰙾",
    "ThunderyShowers": "󰙾",
    "ThunderySnowShowers": "󰙾",
    "VeryCloudy": "󰖐󰖐",
}

const NIGHT_MAP = {"󰖙": "󰖔", "󰖕": "󰼱"}

def is_night [astronomy: record] {
    let now_utc = date now

    let sunrise = $astronomy.sunrise | into datetime
    let sunset = $astronomy.sunset | into datetime

    $now_utc > $sunset or $now_utc < $sunrise
}

def get_icon [condition: string, is_night: bool] {
    let icon = $WEATHER_ICONS | get -i $condition | default $WEATHER_ICONS.Unknown;

    if $is_night {
        $NIGHT_MAP | get -i $icon | default $icon
    } else {
        $icon
    }
}

def error-exit [msg: string] {
    let out = {
        text: "󰧠",
        tooltip: $"Failed to fetch weather:\n($msg)",
        class: ["Unknown"]
    };
    print ($out | to json -r)
    exit
}

def main [] {

    let raw = try {
        http get https://wttr.in/?format=j1&lang=us
    } catch { |err|
        error-exit $err.msg;
    }

    if ($raw | str starts-with "Unknown location;") {
        error-exit $raw;
    }

    let current_condition = $raw.current_condition.0
    let weather = $raw.weather.0
    let astronomy = $weather.astronomy.0
    let area = $raw.nearest_area.0

    let condition = $WWO_CODE | get -i $current_condition.weatherCode | default "Unknown"

    let night = is_night $astronomy

    let icon = get_icon $condition $night

    let text = $"($icon) ($current_condition.temp_F) °F"
    let tooltip = [
        $condition,
        $"Temperature: ($current_condition.temp_F) °F",
        $"Feels like ($current_condition.FeelsLikeF) °F",
        $"High of ($weather.maxtempF) °F / Low of ($weather.mintempF) °F",
        $"($current_condition.humidity)% Humidity",
        $"($current_condition.pressure) in. Pressure",
        $"($current_condition.uvIndex) UV Index",
        $"($current_condition.precipInches) in. Precipitation",
        $"($current_condition.visibilityMiles) mi. Visibility",
        $"($current_condition.windspeedMiles) mph Wind, Going ($current_condition.winddir16Point)",
        $"Sunrise: ($astronomy.sunrise) / Sunset: ($astronomy.sunset)",
        $"Location: ($area.areaName.0.value), ($area.region.0.value), ($area.country.0.value)",
        "Fetched from https://wttr.in"
    ] | str join "\n"

    let out = {
        text: $text,
        tooltip: $tooltip,
        class: [$condition, (if $night { "night" } else { "day" })]
    }

    print ($out | to json -r)

}
