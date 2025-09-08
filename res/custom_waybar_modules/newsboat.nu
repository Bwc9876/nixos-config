#!/usr/bin/env nu

const WAIT: duration = 30min;

let NB_DB = $"($env.HOME)/.local/share/newsboat/cache.db";

let nb_running = (pidof "newsboat" | complete).exit_code == 0;

let need_cooldown =  ((date now) - (ls $NB_DB | first | get modified)) < $WAIT;

if (not $need_cooldown and not $nb_running) {
    let refreshing = {
        text: "󰎕 ",
        tooltip: "Newsboat - refreshing",
        class: "refreshing",
    };
    print ($refreshing | to json -r);
    newsboat -x reload | ignore;
}

# Otherwise newsboat will complain about the database being locked
let unread = open $NB_DB | get rss_item | where unread == 1 | length

let output = {
    text: (if $unread != 0 { $"󰎕 ($unread)" } else { "󰎕" }),
    tooltip: $"Newsboat - ($unread) unread (if $unread == 1 { "entry" } else { "entries" })",
    class: (if $unread > 0 { "unread" } else { "utd" }),
};

print ($output | to json -r);
