#!/usr/bin/env nu

const YT_REGEX = "(?:https?:\\/\\/)?(?:www\\.)?(?:youtu\\.be\\/|youtube\\.com\\/(?:embed\\/|v\\/|playlist\\?|watch\\?v=|watch\\?.+(?:&|&#38;);v=))([a-zA-Z0-9\\-_]{11})?(?:(?:\\?|&|&#38;)index=((?:\\d){1,3}))?(?:(?:\\?|&|&#38;)?list=([a-zA-Z\\-_0-9]{34}))?(?:\\S+)?"

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
        xdg-open $url
    } else if ($type | str starts-with "image/") {
        http get $url | kitten icat
        input "Press enter to close the image viewer"
    } else if ($type | str starts-with "video/") or ($url =~ $YT_REGEX) {
        qmplay2 --open $url
    } else if ($type | str starts-with "text/html") {
        let w3m_opts = $"-no-cookie -o confirm_qq=FALSE -o display_link_number=TRUE -o extbrowser=($env.CURRENT_FILE)";
        let w3m_cmd = $"w3m ($w3m_opts)";
        let s = (term size).columns;
        stty cols 90;        
        try {
            rdrview "-B" $w3m_cmd $url 
        } catch {
            bash -c $"($w3m_cmd) ($url)"
        }
        stty cols $s
    } else if ($type | str starts-with "text/") {
        let txt = http get $url;
        let filename = $url | split row "/" | last | split row "?" | first;
        $txt | bat "--paging" "always" "--file-name" $filename
    } else {
        xdg-open $url
    }
}
