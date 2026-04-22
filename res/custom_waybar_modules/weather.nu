#!/usr/bin/env nu

def search_loc [name: string] {
    let params = {
        name: $name,
        count: 1,
        language: "en",
        format: "json"
    } | url build-query;
    let endpoint = "https://geocoding-api.open-meteo.com/v1/search";

    let resp = http get $"($endpoint)?($params)" | get -o results;

    if (($resp == null) or ($resp | is-empty)) {
        error make $"No geocode data for city: ($name)"
    } else {
       $resp | first | select latitude longitude
    }
}

def query_weather [loc: record<latitude: float, longitude: float>] {
    let loc_params = $loc | url build-query;
    let current_fields = [
        temperature_2m
        apparent_temperature
        is_day
        precipitation
        relative_humidity_2m
        weather_code
    ] | str join ",";
    let hourly_fields = [
        temperature_2m
        precipitation
        precipitation_probability
        weather_code
        is_day
    ] | str join ",";
    let daily_fields = [
        sunrise
        sunset
        temperature_2m_max
        temperature_2m_min
        weather_code
        precipitation_probability_max
    ] | str join ",";

    let opt_params = {
        forecast_days: 7,
        forecast_hours: 12,
        wind_speed_unit: "mph",
        temperature_unit: "fahrenheit",
        precipitation_unit: "inch",
        timezone: "auto",
        current: $current_fields,
        hourly: $hourly_fields,
        daily: $daily_fields,
    } | url build-query;

    let params = $"($loc_params)&($opt_params)";

    let endpoint = "https://api.open-meteo.com/v1/forecast";

    http get $"($endpoint)?($params)"
}

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

const NIGHT_MAP = {"󰖙": "󰖔", "󰖕": "󰼱"};

const WEATHER_ICONS = {
    "Unknown": "󰨹",
    "Error": "󰧠",
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
    "VeryCloudy": "",
};

const WEATHER_DESCS = {
    "Unknown": "mysterious",
    "Cloudy": "cloudy",
    "Fog": "foggy",
    "HeavyRain": "heavily raining",
    "HeavyShowers": "heavily showering",
    "HeavySnow": "heavily snowing",
    "HeavySnowShowers": "heavily raining and snowing",
    "LightRain": "lightly raining",
    "LightShowers": "lightly showering",
    "LightSleet": "lightly sleeting",
    "LightSleetShowers": "lightly sleeting and raining",
    "LightSnow": "lightly snowing",
    "LightSnowShowers": "lightly snowing and showering",
    "PartlyCloudy": "partly cloudy",
    "Sunny": "sunny",
    "ThunderyHeavyRain": "heavily thunderstorming",
    "ThunderyShowers": "thunderstorming",
    "ThunderySnowShowers": "thunder and snow-storming",
    "VeryCloudy": "very cloudy",
};

def get_icon [cond: string, is_day: int] {
    let icon = $WEATHER_ICONS | get -o $cond | default $WEATHER_ICONS.Unknown;

    if $is_day == 0 {
        $NIGHT_MAP | get -o $icon | default $icon
    } else {
        $icon
    }
}

def get_desc [cond: string] {
    $WEATHER_DESCS | get -o $cond | default $WEATHER_DESCS.Unknown
}

def mk_condition [r: record, is_day: int] {
    let cond = match_wmo_code $r.weather_code;

    $"(get_icon $cond $is_day) (get_desc $cond)"
}

def evil_transpose [a: record] {
    0..($a | values | get 0 | length | $in - 1) | each {|i| $a | columns | each {|c| [$c, ($a | get $c | get $i)]} | into record}
}

def mk_text [weather: record] {
    let icon = get_icon (match_wmo_code $weather.current.weather_code) $weather.current.is_day;
    let temp = $weather.current.temperature_2m | math round;
    let unit = $weather.current_units.temperature_2m;

    $"($icon) ($temp)($unit)"
}

def mk_current_text [weather: record] {
    let c = $weather.current;
    let u = $weather.current_units;
    let cond = match_wmo_code $c.weather_code;
    let today = (evil_transpose $weather.daily) | first;

    [
        $"󱃂  ($c.temperature_2m | math round)($u.temperature_2m) \(Feels like ($c.apparent_temperature | math round)($u.apparent_temperature)\)"
        $"(get_icon $cond $c.is_day)  (get_desc $cond | str title-case)"
        $"  ($c.precipitation) ($u.precipitation)(if $c.precipitation == 1 { '' } else { 'es' })"
        $"  ($c.relative_humidity_2m)($u.relative_humidity_2m)"
        $"󰖜  ($today.sunrise | into datetime | format date '%I:%M %p')"
        $"󰖛  ($today.sunset | into datetime | format date '%I:%M %p')"
    ] | str join "\n" 
}

def mk_hour_line [h: record, u: record] {
    let nice_time = $h.time | into datetime | format date "%_I %p";
    let cond = match_wmo_code $h.weather_code;
    $"(get_icon $cond $h.is_day)  ($nice_time) | ($h.temperature_2m | math round)($u.temperature_2m), ($h.precipitation_probability)($u.precipitation_probability)"
}

def mk_hourly_text [weather: record] {
   let hours = evil_transpose $weather.hourly
   let u = $weather.hourly_units;

   $hours | skip 1 | each {mk_hour_line $in $u} | str join "\n"
}

def mk_daily_line [d: record, u: record] {
    let cond = match_wmo_code $d.weather_code;
    $"(get_icon $cond 1)   ($d.time | into datetime | format date "%a"). | ($d.temperature_2m_min | math round)($u.temperature_2m_min) / ($d.temperature_2m_max | math round)($u.temperature_2m_max), ($d.precipitation_probability_max)($u.precipitation_probability_max)"
}

def mk_daily_text [weather: record] {
    let days = evil_transpose $weather.daily;
    let u = $weather.daily_units;

    $days | each {mk_daily_line $in $u} | str join "\n"
}

def mk_tooltip [weather: record, city: string] {
    [
      $"<b>Current Weather in ($city)</b>"
      (mk_current_text $weather)
      " "
      "<b>Hourly Forecast</b>"
      (mk_hourly_text $weather)
      " "
      "<b>Daily Forecast</b>"
      (mk_daily_text $weather)
    ] | str join "\n" 
}

def mk_waybar_module [city: string] {
    let cache_loc_name = $"nu-waybar-loc-($city | hash sha256).json";
    let cache_loc_path = $env | get -o "TMPDIR" | default "/tmp" | path join $cache_loc_name;

    let loc = if ($cache_loc_path | path exists) {
        try { 
            let cached_loc = open $cache_loc_path;
            if ($cached_loc | describe) != ({latitude: 0.0, longitude: 0.0} | describe) {
                error make "Invalid cache"
            }
            $cached_loc
        } catch {
            let new_loc = search_loc $city
            $new_loc | save -f $cache_loc_path
            $new_loc
        }
    } else {
        let new_loc = search_loc $city;
        $new_loc | save $cache_loc_path
        $new_loc
    };

    let w = query_weather $loc;

    { 
        text: (mk_text $w), 
        tooltip: (mk_tooltip $w $city),
        class: [(match_wmo_code $w.current.weather_code), (if $w.current.is_day == 1 { "day" } else { "night" })],
    }
}

def mk_error_module [msg: string] {
    { 
        text: $"($WEATHER_ICONS.Error) Err", 
        tooltip: $"Failed to fetch weather\n\n($msg)",
        class: ["Error"],
    }
}

def main [] {
    let city = http get "https://ipapi.co/json" | get city;
    
    let out = try {
        mk_waybar_module $city
    } catch {|err|
        mk_error_module $err.rendered
    };

    $out | to json -r
}

