#!/usr/bin/env nu

def main [base: path = .] {
  let bookmarks = rg ".+: <https://.*>" $base --json | lines | par-each {from json} 
                          | where type == "match" | get data;

  let bookmarks_disp = $bookmarks | par-each {|it| 
    let s = $it.lines.text | str trim | str trim --char "-"  | str trim | split row "<";
    let display = $s | first | str trim | str trim --char ":" | str replace --all "&" "&amp;";
    let url = $s | get 1 | str trim --char ">" | str trim;
    let disp_url = $url | str replace "https://" "" | str trim --char "/" | str replace --all "&" "&amp;";
    let m = char --integer 0x1f;
    let file = $it.path.text | str trim | path basename;
    $"($url)|($display)|($file)(char --integer 0x0)display($m)($display) <small>($disp_url)</small>"
  };

  let choice = $bookmarks_disp | str join "\n" | rofi -i -dmenu -markup-rows | split row "|" | first;

  xdg-open $choice;
}
