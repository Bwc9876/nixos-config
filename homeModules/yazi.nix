{...}: {
  config,
  lib,
  pkgs,
  ...
}: {
  options.cow.yazi.enable =
    lib.mkEnableOption "Yazi + Customizations"
    // {
      default = true;
    };

  config = lib.mkIf config.cow.yazi.enable {
    home.packages = with pkgs; [
      yazi
      mediainfo
      exiftool
    ];

    programs.yazi = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;

      settings = {
        open.prepend_rules = [
          {
            mime = "video/*";
            use = "open";
          }
          {
            mime = "audio/*";
            use = "open";
          }
        ];
      };

      keymap.mgr.prepend_keymap = [
        {
          run = "plugin mount";
          on = ["M"];
          desc = "Disk Mounting";
        }
        {
          run = "plugin chmod";
          on = [
            "c"
            "m"
          ];
          desc = "Run Chmod On Selected";
        }
      ];

      plugins = {
        inherit
          (pkgs.yaziPlugins)
          ouch
          mount
          chmod
          bypass
          mediainfo
          wl-clipboard
          yatline-catppuccin
          ;
        yatline = pkgs.yaziPlugins.yatline.overrideAttrs (
          _: _: {
            version = "25.5.31-unstable-2026-01-05";
            src = pkgs.fetchFromGitHub {
              owner = "carlosedp";
              repo = "yatline.yazi";
              rev = "e9589884cbdd7cc2283523fdb94f1c4c717a6de7";
              sha256 = "sha256-TiMY4XEfrHUKDDw1GRoYQU4mjrIEPEy7NwDoYuUyMic=";
            };
          }
        );
      };

      initLua = ''
        local catppuccin_theme = require("yatline-catppuccin"):setup("mocha")

        require("yatline"):setup({
        	theme = catppuccin_theme,
        	section_separator = { open = "", close = "" },
        	part_separator = { open = "", close = "" },
        	inverse_separator = { open = "", close = "" },

        	tab_width = 20,
        	tab_use_inverse = false,

        	selected = { icon = "󰻭", fg = "yellow" },
        	copied = { icon = "", fg = "green" },
        	cut = { icon = "", fg = "red" },

        	total = { icon = "󰮍", fg = "yellow" },
        	succ = { icon = "", fg = "green" },
        	fail = { icon = "", fg = "red" },
        	found = { icon = "󰮕", fg = "blue" },
        	processed = { icon = "󰐍", fg = "green" },

        	show_background = true,

        	display_header_line = true,
        	display_status_line = true,

        	component_positions = { "header", "tab", "status" },

        	header_line = {
        		left = {
        			section_a = {
                			{type = "line", custom = false, name = "tabs", params = {"left"}},
        			},
        			section_b = {
        			},
        			section_c = {
        			}
        		},
        		right = {
        			section_a = {
                			{type = "string", custom = false, name = "date", params = {"%A, %d %B %Y"}},
        			},
        			section_b = {
                			{type = "string", custom = false, name = "date", params = {"%X"}},
        			},
        			section_c = {
        			}
        		}
        	},

        	status_line = {
        		left = {
        			section_a = {
                			{type = "string", custom = false, name = "tab_mode"},
        			},
        			section_b = {
                			{type = "string", custom = false, name = "hovered_size"},
        			},
        			section_c = {
                			{type = "string", custom = false, name = "hovered_path"},
                			{type = "coloreds", custom = false, name = "count"},
        			}
        		},
        		right = {
        			section_a = {
                			{type = "string", custom = false, name = "cursor_position"},
        			},
        			section_b = {
                			{type = "string", custom = false, name = "cursor_percentage"},
        			},
        			section_c = {
                			{type = "string", custom = false, name = "hovered_file_extension", params = {true}},
                			{type = "coloreds", custom = false, name = "permissions"},
        			}
        		}
        	},
        })
      '';
    };
  };
}
