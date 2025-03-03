#!/usr/bin/env nu

let img = grimblast save area -

let txt = $img | tesseract - - -l eng e> /dev/null | str trim

$txt | wl-copy

echo $"Copied \"($txt)\" to clipboard"

