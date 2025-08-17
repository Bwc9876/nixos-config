{
  pkgs,
  inputs,
  config,
  lib,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    ripgrep
    fd
  ];

  home-manager.users.bean = {
    imports = [ inputs.nixvim.homeModules.nixvim ];

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
          term_colors = true;
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
                errors = [ "italic" ];
                hints = [ "italic" ];
                information = [ "italic" ];
                warnings = [ "italic" ];
                ok = [ "italic" ];
              };
              underlines = {
                errors = [ "underline" ];
                hints = [ "underline" ];
                information = [ "underline" ];
                warnings = [ "underline" ];
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
        vim.g.neovide_cursor_vfx_mode = "pixiedust"

        require("satellite").setup({})
      '';

      autoGroups = {
        restore_cursor = { };
        open_neotree = { };
      };

      filetype.extension.mdx = "mdx";

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
        mouse = "";
      };

      autoCmd = [
        {
          group = "restore_cursor";
          event = [ "BufReadPost" ];
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
          event = [ "BufRead" ];
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

      keymaps =
        let
          prefixMap =
            pre: maps:
            builtins.map (k: {
              action = "<cmd>${k.action}<cr>";
              key = "${pre}${k.key}";
              options = k.options;
            }) maps;
        in
        lib.lists.flatten (
          builtins.map (g: if builtins.hasAttr "group" g then prefixMap g.prefix g.keys else g) [
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
              action = ''<cmd>Format<cr>'';
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
                  action = "BufferLinePick";
                  key = "<Tab>";
                  options.desc = "Pick Tab and Switch";
                }
              ];
            }
            {
              group = "Tab Closing";
              prefix = "<S-Tab>";
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
              keys = [
                {
                  action = "Lspsaga code_action code_action";
                  key = "a";
                  options.desc = "Code Actions";
                }
                {
                  action = "Lspsaga rename";
                  key = "r";
                  options.desc = "LSP Rename";
                }
                {
                  action = "Lspsaga diagnostic_jump_next";
                  key = "e";
                  options.desc = "Next Diagnostic";
                }
                {
                  action = "Lspsaga diagnostic_jump_previous";
                  key = "E";
                  options.desc = "Previous Diagnostic";
                }
                {
                  action = "Lspsaga goto_definition";
                  key = "d";
                  options.desc = "Jump to Definition";
                }
                {
                  action = "Lspsaga peek_definition";
                  key = "D";
                  options.desc = "Peek Definition";
                }
                {
                  action = "Lspsaga finder ref";
                  key = "fr";
                  options.desc = "Find References";
                }
                {
                  action = "Lspsaga finder imp";
                  key = "fi";
                  options.desc = "Find Implementations";
                }
                {
                  action = "Lspsaga finder def";
                  key = "fd";
                  options.desc = "Find Definitions";
                }
                {
                  action = "Lspsaga finder";
                  key = "ff";
                  options.desc = "Finder";
                }
                {
                  action = "Lspsaga hover_doc";
                  key = "h";
                  options.desc = "Hover Doc";
                }
              ];
            }
            {
              action = "<cmd>Telescope<cr>";
              key = "<leader><leader>";
              options.desc = "Telescope Launch";
            }
            {
              action.__raw = "[[<C-\\><C-n><C-w>]]";
              mode = [ "t" ];
              key = "<C-w>";
            }
            {
              action.__raw = "[[<C-\\><C-n>]]";
              mode = [ "t" ];
              key = "<esc>";
            }
            {
              action = "<cmd>WhichKey<cr>";
              key = "<C-/>";
            }
          ]
        );

      extraPlugins = with pkgs.vimPlugins; [
        { plugin = pkgs.nvim-mdx; }
        { plugin = satellite-nvim; }
        { plugin = flatten-nvim; }
        { plugin = tiny-devicons-auto-colors-nvim; }
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
              action = "lsp_document_symbols";
              options.desc = "LSP Symbols";
            };
            "<leader>t" = {
              action = "treesitter";
              options.desc = "Treesitter Symbols";
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
          layout =
            let
              o = {
                position = "center";
              };
              txt = s: {
                type = "text";
                val = s;
                opts = {
                  hl = "Keyword";
                }
                // o;
              };
              grp = g: {
                type = "group";
                val = g;
                opts.spacing = 1;
              };
              btn =
                {
                  val,
                  onClick,
                  ...
                }:
                {
                  type = "button";
                  inherit val;
                  opts = o;
                  on_press.__raw = "function() vim.cmd[[${onClick}]] end";
                };
              cmd =
                {
                  command,
                  width,
                  height,
                }:
                {
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
            ]
            ++ (lib.intersperse pad [
              (cmd {
                command = ''
                  ${pkgs.toilet}/bin/toilet " NIXVIM " -f mono12 -F border | ${pkgs.lolcat}/bin/lolcat -f
                '';
                # Hardcoding to prevent IFD
                width = 83; # (builtins.stringLength (lib.trim (builtins.elemAt (lib.splitString "\n" bannerText) 1))) - 3;
                height = 12; # (builtins.length (lib.splitString "\n" bannerText)) - 1;
              })
              (grp [
                (btn {
                  val = " Terminal";
                  onClick = "ToggleTerm";
                })
                (btn {
                  val = "󰉋 Open Project";
                  onClick = "Telescope projects";
                })
                (btn {
                  val = "󰅙 Quit";
                  onClick = "q";
                })
              ])
              (grp [
                (txt " Neovim Version ${pkgs.neovim.version}")
                (txt " NixVim Rev ${builtins.substring 0 5 inputs.nixvim.rev}")
              ])
            ])
            ++ [ pad ];
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

        treesitter = {
          enable = true;
          luaConfig.post = ''
            require('mdx').setup()
          '';
          settings = {
            highlight.enable = true;
          };
        };

        illuminate.enable = true;
        cursorline.enable = true;

        neocord = {
          enable = true;
          settings.logo = "https://raw.githubusercontent.com/IogaMaster/neovim/main/.github/assets/nixvim-dark.webp";
        };

        bufdelete.enable = true;

        bufferline = {
          enable = true;
          settings.highlights.__raw = ''
            require("catppuccin.groups.integrations.bufferline").get()
          '';
          settings.options = {
            indicator.style = "none";
            show_buffer_close_icons = false;
            show_close_icon = false;
            offsets = [
              {
                filetype = "neo-tree";
                highlight = "String";
                text = " Neovim";
                text_align = "center";
                # separator = true;
              }
            ];
            separator_style = "slant";
            close_command.__raw = ''require('bufdelete').bufdelete'';
            hover = {
              enabled = true;
              delay = 150;
              reveal = [ "close" ];
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
          settings.segments =
            let
              dispCond = {
                __raw = ''
                  function(ln)
                    return vim.bo.filetype ~= "neo-tree"
                  end
                '';
              };
            in
            [
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
                condition = [ dispCond ];
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

        dropbar = {
          enable = true;
          settings = {
            bar.padding.right = 5;
            bar.padding.left = 1;
          };
        };

        nvim-ufo = {
          enable = true;
        };
        gitsigns.enable = true;

        lualine = {
          enable = true;
          settings = {
            extensions = [
              "trouble"
              "toggleterm"
            ];

            options = {
              theme = "catppuccin";
              disabled_filetypes = [ "neo-tree" ];
              ignore_focus = [ "neo-tree" ];
            };
          };
        };

        nix-develop = {
          enable = true;
          package = pkgs.vimPlugins.nix-develop-nvim.overrideAttrs (
            prev: next: {
              src = pkgs.fetchFromGitHub {
                owner = "Bwc9876";
                repo = "nix-develop.nvim";
                rev = "089cd52191ccbb3726594e21cd96567af6088dd5";
                sha256 = "sha256-EIEJk8/IAuG+UICUJ2F8QakgRpFrQ1ezDSJ79NAVuD8=
";
              };
            }
          );
        };

        project-nvim = {
          enable = true;
          enableTelescope = true;
        };

        neo-tree = {
          enable = true;
          hideRootNode = false;
          addBlankLineAtTop = true;
          defaultComponentConfigs = {
            container.rightPadding = 2;
            name.trailingSlash = true;
            indent = {
              indentSize = 2;
              withExpanders = true;
            };
          };
          window.width = 40;
          autoCleanAfterSessionRestore = true;
          closeIfLastWindow = true;
          extraOptions = {
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

        image = {
          luaConfig = {
            pre = "if not vim.g.neovide then";
            post = "end";
          };
          enable = true;
        };
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

        # none-ls = {
        #   enable = true;
        #   sources.formatting = {
        #     prettier = {
        #       enable = true;
        #       disableTsServerFormatter = true;
        #     };
        #     yamlfmt.enable = true;
        #     typstyle.enable = true;
        #     markdownlint.enable = true;
        #   };
        #   sources.diagnostics = {
        #     markdownlint.enable = true;
        #   };
        # };

        cmp = {
          enable = true;
          settings = {
            sources = map (name: { inherit name; }) [
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

        # jupytext.enable = true;

        # Broken
        # hex = {
        #   enable = true;
        #   settings = {
        #     assemble_cmd = "xxd -r";
        #     dump_cmd = "xxd -g 1 -u";
        #   };
        # };

        conform-nvim = {
          enable = true;
          settings.default_format_opts = {
            lsp_format = "prefer";
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
              require("conform").format({ async = true, lsp_format = "fallback", range = range })
            end, { range = true })
          '';
        };

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

        crates.enable = true;

        numbertoggle.enable = true;

        # rustaceanvim.enable = true;
        vim-css-color.enable = true;

        lsp = {
          enable = true;
          inlayHints = true;

          servers = {
            astro.enable = true;
            hls = {
              enable = true;
              installGhc = false;

              ghcPackage = pkgs.haskell.compiler.ghc912;
              package = pkgs.haskell.packages.ghc912.haskell-language-server;
            };
            sqls.enable = true;
            mdx_analyzer = {
              enable = true;
              package = pkgs.mdx-language-server;
            };
            # denols.enable = true;
            ts_ls.enable = true;
            html.enable = true;
            marksman.enable = true;
            cssls.enable = true;
            # tailwindcss.enable = true; Disabled until it doesn't build nodejs from source, bad tailwind
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
            just.enable = true;
          };
        };
      };
    };
  };
}
