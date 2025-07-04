{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    ripgrep
    fd
  ];

  home-manager.users.bean = {
    imports = [inputs.nixvim.homeManagerModules.nixvim];

    programs.nixvim = {
      enable = true;
      enableMan = false;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      nixpkgs.pkgs = pkgs;

      globals.mapleader = " ";

      colorschemes.catppuccin = {
        enable = true;
        settings = {
          inherit (config.catppuccin) flavor;
          no_underline = false;
          no_bold = false;
          no_italics = false;
          # transparent_background = true;
          integrations = {
            alpha = true;
            dropbar.enabled = true;
            fidget = true;
            markdown = true;
            dap = true;
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
            gitsigns = true;
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

      autoGroups = {
        restore_cursor = {};
        open_neotree = {};
      };

      opts = {
        number = true;
        relativenumber = true;
        smartindent = true;
        cursorline = true;
        showtabline = 2;
        breakindent = true;
        fillchars.__raw = ''[[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]'';
        foldcolumn = "1";
        foldlevel = 10;
        foldlevelstart = 10;
        foldenable = true;
      };

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
        {
          group = "open_neotree";
          event = ["BufRead"];
          pattern = "*";
          once = true;
          callback.__raw = ''
            function()
              if
               vim.bo.filetype ~= "alpha"
               and (not vim.g.neotree_opened)
              then
               vim.cmd "Neotree show"
               vim.g.neotree_opened = true
              end
            end
          '';
        }
      ];

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

      keymaps = [
        {
          action = ''"+y'';
          key = "<C-S-C>";
          options.desc = "Copy to System Clipboard";
        }
        {
          action = ''"+p'';
          key = "<C-S-V>";
          options.desc = "Paste from System Clipboard";
        }
        {
          action = ''"+x'';
          key = "<C-S-X>";
          options.desc = "Cut to System Clipboard";
        }
        {
          action = "<cmd>Lspsaga code_action code_action<cr>";
          key = "<C-.>a";
          options.desc = "Code Actions";
        }
        {
          action = "<cmd>Lspsaga rename<cr>";
          key = "<C-.>r";
          options.desc = "LSP Rename";
        }
        {
          action = "<cmd>Lspsaga diagnostic_jump_next<cr>";
          key = "<C-.>e";
          options.desc = "Next Diagnostic";
        }
        {
          action = "<cmd>Lspsaga diagnostic_jump_previous<cr>";
          key = "<C-.>E";
          options.desc = "Previous Diagnostic";
        }
        {
          action = "<cmd>Lspsaga goto_definition<cr>";
          key = "<C-.>d";
          options.desc = "Jump to Definition";
        }
        {
          action = "<cmd>Lspsaga peek_definition<cr>";
          key = "<C-.>D";
          options.desc = "Peek Definition";
        }
        {
          action = "<cmd>Lspsaga finder ref<cr>";
          key = "<C-.>fr";
          options.desc = "Find References";
        }
        {
          action = "<cmd>Lspsaga finder imp<cr>";
          key = "<C-.>fi";
          options.desc = "Find Implementations";
        }
        {
          action = "<cmd>Lspsaga finder def<cr>";
          key = "<C-.>fd";
          options.desc = "Find Definitions";
        }
        {
          action = "<cmd>Lspsaga finder<cr>";
          key = "<C-.>ff";
          options.desc = "Finder";
        }
        {
          action = "<cmd>Lspsaga hover_doc<cr>";
          key = "<C-.>h";
          options.desc = "Hover Doc";
        }
        {
          action = "<cmd>Telescope<cr>";
          key = "<leader><leader>";
          options.desc = "Telescope Launch";
        }
        {
          action = "<cmd>Navbuddy<cr>";
          key = "<leader>j";
          options.desc = "Jump To...";
        }
      ];

      extraPlugins = with pkgs.vimPlugins; [
        {plugin = pkgs.nvim-mdx;}
        {plugin = pkgs.nvim-flatten;}
        {plugin = tiny-devicons-auto-colors-nvim;}
        {plugin = nvim-biscuits;}
      ];

      plugins = {
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
          keymaps = lib.fix (self: {
            "<leader>p" = {
              action = "projects";
              options.desc = "Projects";
            };
            "<leader>u" = {
              action = "undo";
              options.desc = "Undo Tree";
            };
            "<leader>c" = {
              action = "commands";
              options.desc = "Browse Commands";
            };
            "<leader>w" = {
              action = "spell_suggest";
              options.desc = "Spell Suggest";
            };
            "<leader>s" = {
              action = "treesitter";
              options.desc = "Treesitter Symbols";
            };
            "<leader>b" = {
              action = "file_browser";
              options.desc = "File Browser";
            };
            "<leader>f" = {
              action = "find_files";
              options.desc = "Files";
            };
            "<leader>gs" = {
              action = "git_status";
              options.desc = "Git Status";
            };
            "<leader>gb" = {
              action = "git_branches";
              options.desc = "Git Branches";
            };
            "<leader>gc" = {
              action = "git_commits";
              options.desc = "Git Commits";
            };
            "<leader>r" = {
              action = "oldfiles";
              options.desc = "Recent Files";
            };

            "<leader>l" = self."<C-S-F>";
            "<C-S-F>" = {
              action = "live_grep";
              options.desc = "Live Grep";
            };
          });
        };

        alpha = {
          enable = true;
          opts = {
            position = "center";
          };
          layout = let
            o = {
              position = "center";
            };
            txt = s: {
              type = "text";
              val = s;
              opts =
                {
                  hl = "Keyword";
                }
                // o;
            };
            grp = g: {
              type = "group";
              val = g;
              opts.spacing = 1;
            };
            btn = {
              val,
              onClick,
              ...
            }: {
              type = "button";
              inherit val;
              opts = o;
              on_press.__raw = "function() vim.cmd[[${onClick}]] end";
            };
            cmd = {
              command,
              width,
              height,
            }: {
              type = "terminal";
              inherit command width height;
              opts = o;
            };
            pad = {
              type = "padding";
              val = 2;
            };
          in
            [
              pad
              pad
              pad
            ]
            ++ (lib.intersperse pad [
              (
                let
                  banner =
                    pkgs.runCommand "nvim-banner" {}
                    ''${pkgs.toilet}/bin/toilet " NIXVIM " -f mono12 -F border > $out'';
                  # bannerText = builtins.readFile banner;
                in
                  cmd {
                    command = ''open ${banner} | ${pkgs.lolcat}/bin/lolcat -f -S (random int 1..360)'';
                    # Hardcoding to prevent IFD
                    width = 83; # (builtins.stringLength (lib.trim (builtins.elemAt (lib.splitString "\n" bannerText) 1))) - 3;
                    height = 12; # (builtins.length (lib.splitString "\n" bannerText)) - 1;
                  }
              )
              (grp [
                (btn {
                  val = " 󰉋 Open Project";
                  onClick = "Telescope projects";
                  shortcut = "<leader>p";
                })
                (btn {
                  val = " 󱋡 Open Recent File";
                  onClick = "Telescope oldfiles";
                  shortcut = "<leader>r";
                })
                (btn {
                  val = " 󰅙 Quit";
                  onClick = "q";
                  shortcut = "q";
                })
              ])
              (txt "::<シ>")
            ])
            ++ [pad];
        };

        trouble = {
          enable = true;
        };

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
                  if opts.is_blocking and saved_terminal then
                    saved_terminal:close()
                  else
                    vim.api.nvim_set_current_win(opts.winnr)
                  end

                  if ft == "gitcommit" or ft == "gitrebase" then
                    vim.api.nvim_create_autocmd("BufWritePost", {
                      buffer = opts.bufnr,
                      once = true,
                      callback = vim.schedule_wrap(function()
                        vim.api.nvim_buf_delete(opts.bufnr, {})
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
            open_mapping = "[[<C-x>]]";
            direction = "horizontal";
            start_in_insert = true;
            insert_mappings = true;
            terminal_mappings = true;
          };
        };

        treesitter = {
          enable = true;
          languageRegister.mdx = "markdown";
          luaConfig.post = ''
            require('mdx').setup()
          '';
          settings = {
            highlight.enable = true;
          };
        };

        illuminate.enable = true;
        cursorline.enable = true;

        neoscroll = {
          enable = true;
          settings.easing_function = "cubic";
        };
        scrollview.enable = true;

        navbuddy = {
          enable = true;
          lsp.autoAttach = true;
          mappings = {
            "<Left>" = "parent";
            "<Right>" = "children";
            "<Up>" = "previous_sibling";
            "<Down>" = "next_sibling";
            "<C-Left>" = "root";
          };
        };

        neocord = {
          enable = true;
          settings.logo = "https://raw.githubusercontent.com/IogaMaster/neovim/main/.github/assets/nixvim-dark.webp";
        };

        bufdelete.enable = true;

        bufferline = {
          enable = true;
          settings.options = {
            indicator.style = "none";
            close_icon = "";
            buffer_close_icon = "";
            offsets = [
              {
                filetype = "neo-tree";
                text = " Neovim";
                text_align = "center";
                separator = true;
              }
            ];
            separator_style = "slant";
            close_command.__raw = ''require('bufdelete').bufdelete'';
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

        statuscol = {
          enable = true;
          settings.segments = [
            {
              click = "v:lua.ScSa";
              text = [
                "%s"
              ];
            }
            {
              click = "v:lua.ScLa";
              text = [
                {
                  __raw = "require('statuscol.builtin').lnumfunc";
                }
              ];
            }
            {
              click = "v:lua.ScFa";
              condition = [
                true
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

        dropbar.enable = true;

        nvim-ufo = {
          enable = true;
        };
        gitsigns.enable = true;

        dap = {
          enable = true;
        };

        dap-virtual-text.enable = true;

        lualine = {
          enable = true;
          settings = {
            extensions = [
              "trouble"
              "toggleterm"
            ];

            options = {
              theme = "catppuccin";
              disabled_filetypes = ["neo-tree"];
            };
          };
        };

        project-nvim = {
          enable = true;
          enableTelescope = true;
        };

        neo-tree = {
          enable = true;
          addBlankLineAtTop = true;
          window.width = 30;
          closeIfLastWindow = true;
        };

        # image.enable = true;
        web-devicons.enable = true;

        guess-indent.enable = true;
        intellitab.enable = true;

        which-key = {
          enable = true;
          settings = {
            show_help = true;
            preset = "modern";
            win.wo.winblend = 8;
          };
        };

        fidget = {
          enable = true;
          settings.notification = {
            window = {
              align = "top";
              winblend = 0;
            };
          };
        };

        none-ls = {
          enable = true;
          sources.formatting = {
            alejandra.enable = true;
            prettier = {
              enable = true;
              disableTsServerFormatter = true;
            };
            yamlfmt.enable = true;
            typstyle.enable = true;
            markdownlint.enable = true;
          };
          sources.diagnostics = {
            markdownlint.enable = true;
          };
        };

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

        cmp-nvim-lsp.enable = true;
        cmp-nvim-lsp-document-symbol.enable = true;
        cmp-spell.enable = true;

        rainbow-delimiters.enable = true;
        preview.enable = true;

        lsp-format.enable = true;
        lspkind.enable = true;
        # jupytext.enable = true;

        hex = {
          enable = true;
          settings = {
            assemble_cmd = "xxd -r";
            dump_cmd = "xxd -g 1 -u";
          };
        };

        lspsaga = {
          enable = true;
          symbolInWinbar.enable = false;
          lightbulb.enable = false;
          ui = {
            codeAction = "󰛨";
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

        crates.enable = true;

        numbertoggle.enable = true;

        # rustaceanvim.enable = true;
        vim-css-color.enable = true;

        lsp = {
          enable = true;
          inlayHints = true;

          servers = {
            astro.enable = true;
            sqls.enable = true;
            # denols.enable = true;
            ts_ls.enable = true;
            html.enable = true;
            marksman.enable = true;
            cssls.enable = true;
            # tailwindcss.enable = true; Disabled until it doesn't build nodejs from source, bad tailwind!!
            jsonls.enable = true;
            yamlls.enable = true;
            ruff.enable = true;
            csharp_ls.enable = true;
            svelte.enable = true;
            nil_ls.enable = true;
            bashls.enable = true;
            nushell.enable = true;
            taplo.enable = true;
            typos_lsp.enable = true;
            rust_analyzer.enable = true;
            rust_analyzer.installCargo = false;
            rust_analyzer.installRustc = false;
            lemminx.enable = true;
            eslint.enable = true;
            tinymist.enable = true;
          };
        };
      };
    };
  };
}
