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
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      globals.mapleader = " ";

      colorschemes.catppuccin = {
        enable = true;
        settings.flavor = config.catppuccin.flavor;
      };

      performance.byteCompileLua = {
        enable = true;
        nvimRuntime = true;
        plugins = true;
      };

      plugins = {
        telescope = {
          enable = true;
          settings.defaults = {
            layout_config.prompt_position = "top";
          };
          extensions = {
            file-browser.enable = true;
            frecency.enable = true;
            ui-select.enable = true;
          };
          keymaps = {
            "<leader>ff" = {
              action = "find_files";
              options.desc = "Find files with Telescope";
            };
            "<leader>fr" = {
              action = "frecency";
              options.desc = "Open Recently Edited File";
            };
            "<leader>fgs" = {
              action = "git_status";
              options.desc = "Get Git Status";
            };
            "<leader>fgb" = {
              action = "git_branches";
              options.desc = "View Git Branches";
            };
            "<leader>fgc" = {
              action = "git_commits";
              options.desc = "View Git Commits";
            };
            "<C-S-F>" = {
              action = "live_grep";
              options.desc = "Live Grep";
            };
          };
        };

        dashboard.enable = true;

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
        };

        illuminate.enable = true;
        cursorline.enable = true;

        neocord.enable = true;

        barbar = {
          enable = true;
          keymaps = {
            close.key = "<C-q>";
            closeAllButCurrent.key = "<C-S-q-Up>";
            next.key = "<C-Tab>";
            previous.key = "<C-S-Tab>";
          };
        };

        project-nvim = {
          enable = true;
          enableTelescope = true;
        };

        web-devicons.enable = true;

        guess-indent.enable = true;
        indent-blankline.enable = true;
        intellitab.enable = true;

        which-key = {
          enable = true;
          settings = {
            show_help = true;
            preset = "modern";
          };
        };

        # Rust
        # rustaceanvim.enable = true;

        none-ls = {
          enable = true;
          sources.formatting = {
            alejandra.enable = true;
            prettier = {
              enable = true;
              disableTsServerFormatter = true;
            };
            yamlfmt.enable = true;
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
        lsp-status.enable = true;
        lspkind.enable = true;
        jupytext.enable = true;
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
          };
        };

        lsp = {
          enable = true;
          inlayHints = true;

          servers = {
            astro.enable = true;
            ts_ls.enable = true;
            html.enable = true;
            cssls.enable = true;
            jsonls.enable = true;
            yamlls.enable = true;
            pylsp.enable = true;
            nixd.enable = true;
            csharp_ls.enable = true;
            nushell.enable = true;
            taplo.enable = true;
            rust_analyzer.enable = true;
            rust_analyzer.installCargo = false;
            rust_analyzer.installRustc = false;
            lemminx.enable = true;
          };
        };
      };
    };
  };
}
