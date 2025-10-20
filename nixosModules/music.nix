{
  config,
  inputs',
  ...
}: let
  cat =
    (builtins.fromJSON (builtins.readFile "${inputs'.catppuccin.packages.palette}/palette.json"))
    .${config.catppuccin.flavor}.colors;
  accent = cat.${config.catppuccin.accent};
  themeFile = ''
    #![enable(implicit_some)]
    #![enable(unwrap_newtypes)]
    #![enable(unwrap_variant_newtypes)]
    (
        default_album_art_path: None,
        draw_borders: true,
        show_song_table_header: true,
        symbols: (song: "", dir: "", playlist: "󰲸", marker: "\u{e0b0}"),
        layout: Split(
        direction: Vertical,
        panes: [
            (
                size: "3",
                pane: Pane(Tabs),
            ),
            (
                size: "4",
                pane: Split(
                    direction: Horizontal,
                    panes: [
                        (
                            size: "100%",
                            pane: Split(
                                direction: Vertical,
                                panes: [
                                    (
                                        size: "4",
                                        borders: "ALL",
                                        pane: Pane(Header),
                                    ),
                                ]
                            )
                        ),
                    ]
                ),
            ),
            (
                size: "100%",
                pane: Split(
                    direction: Horizontal,
                    panes: [
                        (
                            size: "100%",
                            borders: "ALL",
                            pane: Pane(TabContent),
                        ),
                    ]
                ),
            ),
            (
                size: "3",
                borders: "ALL",
                pane: Pane(ProgressBar),
            ),
        ],
    ),
        progress_bar: (
            symbols: ["[", "=", ">", "-", "]"],
            track_style: (bg: "${cat.mantle.hex}"),
            elapsed_style: (fg: "${accent.hex}", bg: "${cat.mantle.hex}"),
            thumb_style: (fg: "${accent.hex}", bg: "${cat.mantle.hex}"),
        ),
        scrollbar: (
            symbols: ["│", "█", "▲", "▼"],
            track_style: (),
            ends_style: (),
            thumb_style: (fg: "${cat.teal.hex}"),
        ),
        browser_column_widths: [20, 38, 42],
        text_color: "${cat.text.hex}",
        background_color: "${cat.base.hex}",
        header_background_color: "${cat.mantle.hex}",
        modal_background_color: None,
        modal_backdrop: true,
        tab_bar: (active_style: (fg: "black", bg: "${accent.hex}", modifiers: "Bold"), inactive_style: ()),
        borders_style: (fg: "${cat.overlay0.hex}"),
        highlighted_item_style: (fg: "${accent.hex}", modifiers: "Bold"),
        current_item_style: (fg: "black", bg: "${cat.teal.hex}", modifiers: "Bold"),
        highlight_border_style: (fg: "${cat.teal.hex}"),
        cava: (
          bar_symbols: ['▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'],
          inverted_bar_symbols: ['▔', '🮂', '🮃', '▀', '🮄', '🮅', '🮆', '█'],
          bar_width: 1,
          bar_spacing: 1,
          orientation: Bottom,
          bar_color: Gradient({
              0: "${cat.lavender.hex}",
              10: "${cat.blue.hex}",
              20: "${cat.sapphire.hex}",
              30: "${cat.teal.hex}",
              40: "${cat.green.hex}",
              50: "${cat.yellow.hex}",
              60: "${cat.maroon.hex}",
              70: "${cat.red.hex}",
              80: "${cat.mauve.hex}",
              90: "${cat.pink.hex}",
              100: "${cat.flamingo.hex}",
          }),
        ),
        song_table_format: [
            (
                prop: (kind: Property(Artist), style: (fg: "${cat.teal.hex}"), default: (kind: Text("Unknown"))),
                width: "50%",
                alignment: Right,
            ),
            (
                prop: (kind: Text("-"), style: (fg: "${cat.teal.hex}"), default: (kind: Text("Unknown"))),
                width: "1",
                alignment: Center,
            ),
            (
                prop: (kind: Property(Title), style: (fg: "${accent.hex}"), default: (kind: Text("Unknown"))),
                width: "50%",
            ),
        ],
        header: (
            rows: [
                (
                    left: [
                        (kind: Text("["), style: (fg: "${cat.teal.hex}", modifiers: "Bold")),
                        (kind: Property(Status(State)), style: (fg: "${cat.teal.hex}", modifiers: "Bold")),
                        (kind: Text("]"), style: (fg: "${cat.teal.hex}", modifiers: "Bold"))
                    ],
                    center: [
                        (kind: Property(Song(Artist)), style: (fg: "${cat.yellow.hex}", modifiers: "Bold"),
                            default: (kind: Text("Unknown"), style: (fg: "${cat.yellow.hex}", modifiers: "Bold"))
                        ),
                        (kind: Text(" - ")),
                        (kind: Property(Song(Title)), style: (fg: "${accent.hex}", modifiers: "Bold"),
                            default: (kind: Text("No Song"), style: (fg: "${accent.hex}", modifiers: "Bold"))
                        )
                    ],
                    right: [
                        (kind: Text("Vol: "), style: (fg: "${cat.teal.hex}", modifiers: "Bold")),
                        (kind: Property(Status(Volume)), style: (fg: "${cat.teal.hex}", modifiers: "Bold")),
                        (kind: Text("% "), style: (fg: "${cat.teal.hex}", modifiers: "Bold"))
                    ]
                )
            ],
        ),
    )
  '';
  configFile = ''
    #![enable(implicit_some)]
    #![enable(unwrap_newtypes)]
    #![enable(unwrap_variant_newtypes)]
    (
        address: "127.0.0.1:6600",
        password: None,
        theme: Some("catppuccin"),
        cache_dir: None,
        on_song_change: None,
        volume_step: 5,
        max_fps: 30,
        scrolloff: 0,
        wrap_navigation: true,
        enable_mouse: true,
        enable_config_hot_reload: true,
        status_update_interval_ms: 1000,
        rewind_to_start_sec: None,
        reflect_changes_to_playlist: false,
        select_current_song_on_change: false,
        browser_song_sort: [Disc, Track, Artist, Title],
        directories_sort: SortFormat(group_by_type: true, reverse: false),
        album_art: (
            method: Auto,
            max_size_px: (width: 1200, height: 1200),
            disabled_protocols: ["http://", "https://"],
            vertical_align: Center,
            horizontal_align: Center,
        ),
        cava: (
            framerate: 60, // default 60
            autosens: true, // default true
            sensitivity: 100, // default 100
            lower_cutoff_freq: 50, // not passed to cava if not provided
            higher_cutoff_freq: 10000, // not passed to cava if not provided
            input: (
                method: Fifo,
                source: "/tmp/mpd.fifo",
                sample_rate: 44100,
                channels: 2,
                sample_bits: 16,
            ),
            smoothing: (
                noise_reduction: 77, // default 77
                monstercat: false, // default false
                waves: false, // default false
            ),
            eq: []
        ),
        keybinds: (
            global: {
                ":":       CommandMode,
                ",":       VolumeDown,
                "s":       Stop,
                ".":       VolumeUp,
                "<Tab>":   NextTab,
                "<S-Tab>": PreviousTab,
                "1":       SwitchToTab("Queue"),
                "2":       SwitchToTab("Directories"),
                "3":       SwitchToTab("Search"),
                "q":       Quit,
                ">":       NextTrack,
                "p":       TogglePause,
                "<":       PreviousTrack,
                "f":       SeekForward,
                "z":       ToggleRepeat,
                "x":       ToggleRandom,
                "c":       ToggleConsume,
                "v":       ToggleSingle,
                "b":       SeekBack,
                "~":       ShowHelp,
                "u":       Update,
                "U":       Rescan,
                "I":       ShowCurrentSongInfo,
                "O":       ShowOutputs,
                "P":       ShowDecoders,
                "R":       AddRandom,
            },
            navigation: {
                "k":         Up,
                "j":         Down,
                "h":         Left,
                "l":         Right,
                "<Up>":      Up,
                "<Down>":    Down,
                "<Left>":    Left,
                "<Right>":   Right,
                "<C-k>":     PaneUp,
                "<C-j>":     PaneDown,
                "<C-h>":     PaneLeft,
                "<C-l>":     PaneRight,
                "<C-u>":     UpHalf,
                "N":         PreviousResult,
                "a":         Add,
                "A":         AddAll,
                "r":         Rename,
                "n":         NextResult,
                "g":         Top,
                "<Space>":   Select,
                "<C-Space>": InvertSelection,
                "G":         Bottom,
                "<CR>":      Confirm,
                "i":         FocusInput,
                "J":         MoveDown,
                "<C-d>":     DownHalf,
                "/":         EnterSearch,
                "<C-c>":     Close,
                "<Esc>":     Close,
                "K":         MoveUp,
                "D":         Delete,
                "B":         ShowInfo,
            },
            queue: {
                "D":       DeleteAll,
                "<CR>":    Play,
                "<C-s>":   Save,
                "a":       AddToPlaylist,
                "d":       Delete,
                "C":       JumpToCurrent,
                "X":       Shuffle,
            },
        ),
        search: (
            case_sensitive: false,
            mode: Contains,
            tags: [
                (value: "any",         label: "Any Tag"),
                (value: "artist",      label: "Artist"),
                (value: "album",       label: "Album"),
                (value: "albumartist", label: "Album Artist"),
                (value: "title",       label: "Title"),
                (value: "filename",    label: "Filename"),
                (value: "genre",       label: "Genre"),
            ],
        ),
        artists: (
            album_display_mode: SplitByDate,
            album_sort_by: Date,
        ),
        tabs: [
            (
              name: "Queue",
              pane: Split(
                direction: Horizontal,
              panes: [
    		    (size: "60%", pane: Split(
                    direction: Vertical,
                    panes: [
                        (size: "50%", pane: Pane(Queue)),
                        (size: "50%", borders: "TOP", pane: Pane(Cava)),
                    ],
                )),
    		    (size: "40%", borders: "LEFT", pane: Pane(AlbumArt)),
    		    ],
              ),
            ),
            (
                name: "Directories",
                pane: Pane(Directories),
            ),
            (
                name: "Search",
                pane: Pane(Search),
            ),
        ],
    )
  '';
in {
  home-manager.users.bean = {
    programs.cava = {
      enable = true;
    };

    xdg.configFile."rmpc/themes/catppuccin.ron".text = themeFile;

    programs.rmpc = {
      enable = true;
      config = configFile;
    };

    services = {
      mpd = {
        enable = true;
        extraConfig = ''
          audio_output {
            type   "fifo"
            name   "mpd_fifo"
            path   "/tmp/mpd.fifo"
            format "44100:16:2"
          }
          audio_output {
           type			"pipewire"
           name			"Pipewire"
          }
        '';
      };
      mpdris2.enable = true;
    };
  };
}
