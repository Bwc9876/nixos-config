#!/usr/bin/env nu

const YT_REGEX = "(?:https?:\\/\\/)?(?:www\\.)?(?:youtu\\.be\\/|youtube\\.com\\/(?:embed\\/|v\\/|playlist\\?|watch\\?v=|watch\\?.+(?:&|&#38;);v=))([a-zA-Z0-9\\-_]{11})?(?:(?:\\?|&|&#38;)index=((?:\\d){1,3}))?(?:(?:\\?|&|&#38;)?list=([a-zA-Z\\-_0-9]{34}))?(?:\\S+)?"

def disp_text [url: string] {
    let name = $url | url parse | get path | path basename;
    $in | nvim -R -n $"+file ($name)"
}

def fetch_clean_webpage [url: string] {
    try {
        rdrview -B "w3m -no-cookie -dump -cols 90" $url
    } catch {
        w3m -no-cookie -dump -cols 90 $url
    }
}

def main [
    url: string;
] {
    print $"Opening ($url)...";
    let type = try {
        http head $url | where $it.name == "content-type" | first | get value
    } catch {
        "?/?"
    }

    if ($type == "image/svg+xml") {
        # SVGs can't be displayed with kitty's graphics protocol
        xdg-open $url
    } else if ($type | str starts-with "image/") {
        # Simple image viewer
        http get $url | kitten icat
        input "Press enter to close the image viewer"
    } else if ($type | str starts-with "video/") or ($url =~ $YT_REGEX) {
        # QMPlay2 is handy for opening URLs and YT videos directly
        qmplay2 --open $url
    } else if ($type | str starts-with "text/html") {
        # Try to use rdrview to get rid of unimportant parts of the webpage
        # Then render its HTML to a nice format with w3m
        # Finally display in neovim (I don't wanna change the w3m keybinds)
        fetch_clean_webpage $url | disp_text $url;
    } else if ($type | str starts-with "text/") {
        # Simply display text files in neovim, might just merge this
        # with the HTML handler since it would work prolly?
        http get $url | disp_text $url
    } else {
        # Fallback to opening in a GUI app is possible
        xdg-open $url
    }
}
