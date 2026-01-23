{inputs, ...}: {
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [inputs.nixvim.homeModules.nixvim];

  options.cow.neovim.enable = lib.mkEnableOption "Neovim + Nixvim + Customizations";

  config = lib.mkIf config.cow.neovim.enable {
    cow.imperm.keep = [".local/share/nvim"];

    home.sessionVariables.EDITOR = "nvim";

    programs.nixvim = {
      # Meta

      enable = true;
      enableMan = false;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      nixpkgs.pkgs = pkgs;

      performance = {
        byteCompileLua = {
          enable = true;
          nvimRuntime = true;
          plugins = true;
        };
        combinePlugins = {
          enable = true;
        };
      };

      # Theming

      colorschemes.catppuccin = lib.mkIf config.cow.cat.enable {
        enable = true;
        settings = {
          inherit (config.catppuccin) flavor;
          no_underline = false;
          no_bold = false;
          no_italics = false;
          term_colors = true;
          integrations = {
            fidget = true;
            markdown = true;
            ufo = true;
            rainbow_delimiters = true;
            lsp_trouble = true;
            which_key = true;
            telescope.enabled = true;
            treesitter = true;
            lsp_saga = true;
            illuminate = {
              enabled = true;
              lsp = true;
            };
            neotree = true;
            native_lsp = {
              enabled = true;
              inlay_hints = {
                background = true;
              };
              virtual_text = {
                errors = ["italic"];
                hints = ["italic"];
                information = ["italic"];
                warnings = ["italic"];
                ok = ["italic"];
              };
              underlines = {
                errors = ["underline"];
                hints = ["underline"];
                information = ["underline"];
                warnings = ["underline"];
              };
            };
          };
        };
      };

      # Misc. Global Options

      extraConfigLua = ''
        vim.diagnostic.config({
         signs = {
          text = {
           [vim.diagnostic.severity.ERROR] = "",
           [vim.diagnostic.severity.WARN] = "",
          },
         },
        })
      '';

      opts = {
        number = true;
        relativenumber = true;
        smartindent = true;
        cursorline = true;
        showtabline = 2;
        tabstop = 2;
        shiftwidth = 2;
        breakindent = true;
        fillchars.__raw = "[[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]";
        foldcolumn = "1";
        foldlevel = 100;
        foldlevelstart = 100;
        foldenable = true;
        mouse = "";
      };

      # Allow system clipboard copying if graphical env is enabled
      clipboard.providers.wl-copy.enable = lib.mkDefault config.cow.gdi.enable;

      # Associate .mdx extension to mdx buffer type
      filetype.extension = {
        mdx = "mdx";
      };

      # Auto Run Commands

      autoCmd = [
        {
          group = "restore_cursor";
          event = ["BufReadPost"];
          pattern = "*";
          callback.__raw = ''
            function()
              if
                vim.fn.line "'\"" > 1
                and vim.fn.line "'\"" <= vim.fn.line "$"
                and vim.bo.filetype ~= "commit"
                and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1
              then
                vim.cmd "normal! g`\""
              end
            end
          '';
        }
      ];

      autoGroups = {
        # Try to restore cursor to the last position it was at last time this file was opened
        restore_cursor = {};
      };

      # Keybinds

      # globals.mapleader = " ";

      keymaps = let
        prefixMap = group:
          builtins.map (k: {
            action = "<cmd>${
              if group ? "cmdPrefix"
              then group.cmdPrefix + " "
              else ""
            }${k.action}<cr>";
            key = "${group.prefix}${k.key}";
            options = k.options;
          })
          group.keys;
      in
        lib.lists.flatten (
          builtins.map (g:
            if g ? "group"
            then prefixMap g
            else g) [
            {
              action = ''"+p'';
              key = "<C-S-V>";
              options.desc = "Paste from system clipboard";
            }
            {
              action = ''"+y'';
              key = "<C-S-C>";
              options.desc = "Copy to system clipboard";
            }
            {
              action = ''"+x'';
              key = "<C-S-X>";
              options.desc = "Cut to system clipboard";
            }
            {
              action = "<cmd>Format<cr>";
              key = "<C-S-I>";
              options.desc = "Format Buffer";
            }
            {
              group = "Tab Navigation";
              prefix = "<Tab>";
              keys = [
                {
                  action = "BufferLineCycleNext";
                  key = "e";
                  options.desc = "Next Tab";
                }
                {
                  action = "BufferLineCyclePrev";
                  key = "q";
                  options.desc = "Previous Tab";
                }
                {
                  action = "Neotree toggle reveal";
                  key = "t";
                  options.desc = "Toggle Neotree";
                }
              ];
            }
            {
              group = "Tab Closing";
              prefix = "<Tab><Tab>";
              keys = [
                {
                  action = "BufferLineCloseLeft";
                  key = "q";
                  options.desc = "Close Tab Left";
                }
                {
                  action = "BufferLineCloseRight";
                  key = "e";
                  options.desc = "Close Tab Right";
                }
                {
                  action = "BufferLinePickClose";
                  key = "<Tab>";
                  options.desc = "Pick Tab and Close";
                }
                {
                  action = "BufferLineCloseOthers";
                  key = "w";
                  options.desc = "Close Other Tabs";
                }
              ];
            }
            {
              action = "<cmd>Bdelete<cr>";
              key = "<C-q>";
              options.desc = "Close Current Buffer";
            }
            {
              group = "LSP Actions";
              prefix = "<C-.>";
              cmdPrefix = "Lspsaga";
              keys = [
                {
                  action = "code_action code_action";
                  key = "a";
                  options.desc = "Code Actions";
                }
                {
                  action = "rename";
                  key = "r";
                  options.desc = "LSP Rename";
                }
                {
                  action = "diagnostic_jump_next";
                  key = "e";
                  options.desc = "Next Diagnostic";
                }
                {
                  action = "diagnostic_jump_previous";
                  key = "E";
                  options.desc = "Previous Diagnostic";
                }
                {
                  action = "goto_definition";
                  key = "d";
                  options.desc = "Jump to Definition";
                }
                {
                  action = "peek_definition";
                  key = "D";
                  options.desc = "Peek Definition";
                }
                {
                  action = "finder ref";
                  key = "fr";
                  options.desc = "Find References";
                }
                {
                  action = "finder imp";
                  key = "fi";
                  options.desc = "Find Implementations";
                }
                {
                  action = "finder def";
                  key = "fd";
                  options.desc = "Find Definitions";
                }
                {
                  action = "finder";
                  key = "ff";
                  options.desc = "Finder";
                }
                {
                  action = "hover_doc";
                  key = "h";
                  options.desc = "Hover Doc";
                }
              ];
            }
            {
              group = "Telescope";
              prefix = " ";
              cmdPrefix = "Telescope";
              keys = [
                {
                  key = "u";
                  action = "undo";
                  options.desc = "Undo Tree";
                }
                {
                  key = "c";
                  action = "commands";
                  options.desc = "Browse Commands";
                }
                {
                  key = "w";
                  action = "spell_suggest";
                  options.desc = "Spell Suggest";
                }
                {
                  key = "s";
                  action = "lsp_document_symbols";
                  options.desc = "LSP Symbols";
                }
                {
                  key = "t";
                  action = "treesitter";
                  options.desc = "Treesitter Symbols";
                }
                {
                  key = "f";
                  action = "find_files";
                  options.desc = "Files";
                }
                {
                  key = "gs";
                  action = "git_status";
                  options.desc = "Git Status";
                }
                {
                  key = "gb";
                  action = "git_branches";
                  options.desc = "Git Branches";
                }
                {
                  key = "gc";
                  action = "git_commits";
                  options.desc = "Git Commits";
                }
                {
                  key = "r";
                  action = "oldfiles";
                  options.desc = "Recent Files";
                }
                {
                  key = "l";
                  action = "live_grep";
                  options.desc = "Live Grep";
                }
              ];
            }
            {
              action.__raw = "[[<C-\\><C-n><C-w>]]";
              mode = ["t"];
              key = "<C-w>";
            }
            {
              action.__raw = "[[<C-\\><C-n>]]";
              mode = ["t"];
              key = "<esc>";
            }
            {
              action = "<cmd>WhichKey<cr>";
              key = "<C-/>";
            }
          ]
        );

      # Plugins

      dependencies = {
        fd.enable = true;
        ripgrep.enable = true;
        tree-sitter.enable = true;
      };

      extraPlugins = with pkgs.vimPlugins;
        (lib.optional config.cow.dev.web {plugin = pkgs.nvim-mdx;})
        ++ [
          {plugin = flatten-nvim;} # Opens neovim invocations in terminal windows in the current Neovim session
          {plugin = satellite-nvim;} # Scrollbar
          {plugin = tiny-devicons-auto-colors-nvim;} # Color language icons
        ];

      plugins = {
        # Navigation

        # Interactive Fuzzy Search w/ various providers
        telescope = {
          enable = true;
          settings.defaults = {
            layout_config.prompt_position = "top";
          };
          extensions = {
            file-browser.enable = true;
            ui-select.enable = true;
            undo.enable = true;
          };
        };

        # Highlight current row
        illuminate.enable = true;
        # Underline matching token in buffer
        cursorline.enable = true;

        # Nicer bdelete
        bufdelete.enable = true;

        # Tab bar
        bufferline = {
          enable = true;
          settings.highlights.__raw = lib.mkIf config.cow.cat.enable ''
            require("catppuccin.special.bufferline").get_theme()
          '';
          settings.options = {
            indicator.style = "none";
            show_buffer_close_icons = false;
            show_close_icon = false;
            offsets = [
              {
                filetype = "neo-tree";
                highlight = "String";
                text = "Files";
                text_align = "center";
                # separator = true;
              }
            ];
            separator_style = "slant";
            hover = {
              enabled = true;
              delay = 150;
              reveal = ["close"];
            };
            sort_by = "insert_at_end";
            diagnostics = "nvim_lsp";
            diagnostics_indicator.__raw = ''
              function(count, level, diagnostics_dict, context)
               local icon = level:match("error") and " " or " "
               return " " .. icon .. count
              end
            '';
          };
        };

        # Tree file manager
        neo-tree = {
          enable = true;
          settings = {
            hide_root_node = false;
            follow_current_file.enabled = true;
            add_blank_line_at_top = true;
            default_component_configs = {
              container.right_padding = 2;
              name.trailing_slash = true;
              indent = {
                indent_size = 2;
                with_expanders = true;
              };
            };
            window.width = 40;
            auto_clean_after_session_restore = true;
            close_if_last_window = true;
            filesystem.components.name.__raw = ''
              function(config, node, state)
                local components = require('neo-tree.sources.common.components')
                local name = components.name(config, node, state)
                if node:get_depth() == 1 then
                    name.text = vim.fs.basename(vim.loop.cwd() or "") .. "/"
                end
                return name
              end
            '';
          };
        };

        # In-buffer UI/tweaks

        # Toggle relativenumber off when inserting
        numbertoggle.enable = true;

        # Folding implementation
        nvim-ufo.enable = true;

        # Nicer indenting
        indent-o-matic.enable = true;
        intellitab.enable = true;

        # Image Previews
        image.enable = true;

        # Completions
        cmp = {
          enable = true;
          settings = {
            sources = map (name: {inherit name;}) [
              "nvim_lsp"
              "nvim_lsp_signature_help"
              "path"
              "buffer"
            ];
            mapping = {
              "<Esc>" = "cmp.mapping.abort()";
              "<Tab>" = "cmp.mapping.confirm({ select = true })";
              "<Up>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
              "<Down>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            };
          };
        };

        # LSP Completion providers
        cmp-nvim-lsp.enable = true;
        cmp-nvim-lsp-document-symbol.enable = true;

        # Common Spellings
        cmp-spell.enable = true;

        # Color-coded matching symbols
        rainbow-delimiters.enable = true;

        # Line number column + LSP + folding + etc.
        statuscol = {
          enable = true;
          settings.segments = let
            dispCond = {
              __raw = ''
                function(ln)
                  return vim.bo.filetype ~= "neo-tree"
                end
              '';
            };
          in [
            {
              click = "v:lua.ScSa";
              condition = [
                dispCond
              ];
              text = [
                "%s"
              ];
            }
            {
              click = "v:lua.ScLa";
              condition = [dispCond];
              text = [
                {
                  __raw = "require('statuscol.builtin').lnumfunc";
                }
              ];
            }
            {
              click = "v:lua.ScFa";
              condition = [
                dispCond
                {
                  __raw = "require('statuscol.builtin').not_empty";
                }
              ];
              text = [
                {
                  __raw = "require('statuscol.builtin').foldfunc";
                }
                " "
              ];
            }
          ];
        };

        # Informational bottom line
        lualine = {
          enable = true;
          settings = {
            extensions = [
              "trouble"
              "toggleterm"
            ];

            options = {
              theme = lib.mkIf config.cow.cat.enable "catppuccin";
              disabled_filetypes = ["neo-tree"];
              ignore_focus = ["neo-tree"];
            };
          };
        };

        # New Windows

        # Nice notifications and progress indicator
        fidget = {
          enable = true;
          settings.notification = {
            override_vim_notify = true;
            window = {
              y_padding = 2;
              x_padding = 2;
              zindex = 50;
              align = "top";
              winblend = 0;
            };
          };
        };

        # Interactive keybind helper
        which-key = {
          enable = true;
          settings = {
            show_help = true;
            preset = "modern";
            win.wo.winblend = 8;
          };
        };

        # Toggle a Terminal Window
        toggleterm = {
          enable = true;
          luaConfig.post = ''
            local flatten = require('flatten')

            ---@type Terminal?
            local saved_terminal

            flatten.setup({
              hooks = {
                should_block = function(argv)
                  return vim.tbl_contains(argv, "-b")
                end,
                pre_open = function()
                  local term = require("toggleterm.terminal")
                  local termid = term.get_focused_id()
                  saved_terminal = term.get(termid)
                end,
                post_open = function(opts)
                  if saved_terminal then
                    saved_terminal:close()
                  else
                    vim.api.nvim_set_current_win(opts.winnr)
                  end

                  if opts.filetype == "gitcommit" or opts.filetype == "gitrebase" then
                    vim.api.nvim_create_autocmd("BufWritePost", {
                      buffer = opts.bufnr,
                      once = true,
                      callback = vim.schedule_wrap(function()
                        require('bufdelete').bufdelete(opts.bufnr, true)
                      end),
                    })
                  end
                end,
                block_end = function()
                  vim.schedule(function()
                    if saved_terminal then
                      saved_terminal:open()
                      saved_terminal = nil
                    end
                  end)
                end,
              },
              window = {
                open = "alternate",
              },
            })
          '';
          settings = {
            size = 20;
            open_mapping = "[[<C-x>]]";
            direction = "horizontal";
            start_in_insert = true;
            insert_mappings = true;
            terminal_mappings = true;
          };
        };

        # Language Integration and LSPs

        # Provider for syntax highlighting, symbols, etc. when not using an LSP
        treesitter = {
          enable = true;
          luaConfig.post = lib.mkIf config.cow.dev.web ''
            require('mdx').setup()
          '';
          settings = {
            highlight = {
              enable = true;
              additional_vim_regex_highlighting = false;
            };
            indent.enable = true;
          };
        };

        # Formatting code using multiple providers
        conform-nvim = {
          enable = true;
          settings = {
            formatters.treefmt = {
              require_cwd = false;
            };
            formatters_by_ft = {
              "*" = ["treefmt"];
            };
            default_format_opts = {
              lsp_format = "fallback";
            };
          };
          # Taken from https://github.com/stevearc/conform.nvim/blob/master/doc/recipes.md#format-command
          luaConfig.post = ''
            vim.api.nvim_create_user_command("Format", function(args)
              local range = nil
              if args.count ~= -1 then
                local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
                range = {
                  start = { args.line1, 0 },
                  ["end"] = { args.line2, end_line:len() },
                }
              end
              require("conform").format({ range = range, timeout_ms = 5000 })
            end, { range = true })
          '';
        };

        # Common buffer type associations to activate LSPs
        lspconfig.enable = true;

        # UI for many LSP features
        lspsaga = {
          enable = true;
          settings = {
            symbol_in_winbar.enable = false;
            implement.enable = false;
            lightbulb.enable = false;
            ui = {
              code_action = "󰛨";
              actionfix = "󰖷";
            };
            hover = {
              openCmd = "!xdg-open";
              openLink = "<leader>o";
              maxWidth = 0.5;
              maxHeight = 0.4;
            };
            rename.autoSave = true;
            finder = {
              keys.close = "<ESC>";
            };
            codeAction.keys.quit = "<ESC>";
          };
        };

        # Get latest version of deps in a Cargo.toml as inline hints
        crates.enable = lib.mkDefault config.cow.dev.rust;

        # Better TS LSP, etc.
        typescript-tools.enable = lib.mkDefault config.cow.dev.web;

        # Misc. UI

        # UI and provider for diagnostics
        trouble = {
          enable = true;
        };

        # Icons used in many places for languages
        web-devicons.enable = true;
      };

      lsp = lib.mkDefault {
        inlayHints.enable = true;

        servers = let
          inherit
            (config.cow.dev)
            dotnet
            python
            haskell
            rust
            web
            c
            ;
        in {
          clangd.enable = c;
          astro.enable = web;
          hls = lib.mkIf haskell {
            enable = true;
            # ghcPackage = pkgs.haskell.compiler.ghc912;
            package = pkgs.haskell.packages.ghc912.haskell-language-server;
          };
          mdx_analyzer = lib.mkIf web {
            enable = true;
            package = pkgs.mdx-language-server;
          };
          # ts_ls.enable = web;
          html.enable = web;
          marksman.enable = web;
          cssls.enable = web;
          jsonls.enable = web;
          yamlls.enable = web;
          ruff.enable = python;
          csharp_ls.enable = dotnet;
          nil_ls.enable = true;
          bashls.enable = true;
          nushell.enable = config.cow.nushell.enable;
          taplo.enable = rust;
          typos_lsp.enable = true;
          rust_analyzer = lib.mkIf rust {
            enable = true;
            package = pkgs.rust-analyzer-nightly;
            packageFallback = true;
          };
          lemminx.enable = web;
          eslint.enable = web;
          just.enable = config.cow.utils.enable;
        };
      };
    };
  };
}
