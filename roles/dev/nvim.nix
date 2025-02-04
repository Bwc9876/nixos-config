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
        settings.flavor = config.catppuccin.flavor;
      };

      autoGroups = {
        restore_cursor = {};
      };

      opts = {
        number = true;
        relativenumber = true;
        smartindent = true;
        cursorline = true;
        showtabline = 2;
        breakindent = true;
        # fillchars.__raw = "[[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]";
        # foldcolumn = "1";
      };

      autoCmd = [
        {
          group = "restore_cursor";
          event = ["BufReadPost"];
          pattern = "*";
          callback = {
            __raw = ''
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
          };
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

      extraPlugins = with pkgs.vimPlugins; [{plugin = pkgs.callPackage "${inputs.self}/pkgs/nvim-mdx.nix" {};} {plugin = tiny-devicons-auto-colors-nvim;} {plugin = nvim-biscuits;}];

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
            o = {position = "center";};
            txt = s: {
              type = "text";
              val = s;
              opts = {hl = "Keyword";} // o;
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
            [pad pad pad]
            ++ (lib.intersperse pad [
              (let
                banner = pkgs.runCommand "nvim-banner" {} ''${pkgs.toilet}/bin/toilet " NIXVIM " -f mono12 -F border > $out'';
                # bannerText = builtins.readFile banner;
              in
                cmd {
                  command = ''mut i = 1; loop { let s = (open ${banner}) | ${pkgs.lolcat}/bin/lolcat -f -S $i; clear; print -n -r $s; sleep 50ms; $i += 3; }'';
                  # Hardcoding to prevent IFD
                  width = 83; #(builtins.stringLength (lib.trim (builtins.elemAt (lib.splitString "\n" bannerText) 1))) - 3;
                  height = 12; #(builtins.length (lib.splitString "\n" bannerText)) - 1;
                })
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

        barbar = {
          enable = true;
          keymaps = {
            close.key = "<C-q>";
            closeAllButCurrent.key = "<C-S-q-Up>";
            next.key = "<C-Tab>";
            previous.key = "<C-S-Tab>";
          };
          settings.icons = {
            diagnostics."vim.diagnostic.severity.ERROR".enabled = true;
            diagnostics."vim.diagnostic.severity.WARN".enabled = true;
          };
        };

        statuscol = {
          enable = true;
        };

        # nvim-ufo.enable = true;
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
          };
        };

        project-nvim = {
          enable = true;
          enableTelescope = true;
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
            overrideVimNotify = true;
            window.align = "top";
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
            mapping = lib.fix (self: {
              "<Esc>" = "cmp.mapping.abort()";
              "<CR>" = "cmp.mapping.confirm({ select = true })";
              "<Up>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
              "<Down>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
              "<Tab>" = self."<Up>";
              "<S-Tab>" = self."<Down>";
            });
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
        hex.enable = true;

        lspsaga = {
          enable = true;
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
            denols.enable = true;
            ts_ls.enable = true;
            html.enable = true;
            marksman.enable = true;
            cssls.enable = true;
            tailwindcss.enable = true;
            jsonls.enable = true;
            yamlls.enable = true;
            pylsp.enable = true;
            csharp_ls.enable = true;
            svelte.enable = true;
            nil_ls.enable = true;
            bashls.enable = true;
            nushell.enable = true;
            taplo.enable = true;
            rust_analyzer.enable = true;
            rust_analyzer.installCargo = false;
            rust_analyzer.installRustc = false;
            lemminx.enable = true;
            eslint.enable = true;
          };
        };
      };
    };
  };
}
