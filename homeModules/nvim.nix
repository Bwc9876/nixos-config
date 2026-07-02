{
  config,
  lib,
  ...
}: {
  options.cow.neovim.enable = lib.mkEnableOption "Neovim + Nvf + Customizations";

  config = lib.mkIf config.cow.neovim.enable {
    cow.imperm.keep = [".local/share/nvim"];

    home.sessionVariables.EDITOR = "nvim";

    programs.nvf = let
      dev = config.cow.dev;
      ifCat = lib.mkIf config.cow.cat.enable;
    in {
      enable = true;
      settings.vim = {
        enableLuaLoader = true;
        viAlias = true;
        vimAlias = true;

        bell = "visual";

        utility = {
          ccc.enable = true;
          images.image-nvim.enable = true;
          mkdir.enable = true;
          motion.hop.enable = true;
          nix-develop.enable = true;
          surround.enable = true;
          undotree.enable = true;
          yazi-nvim.enable = true;
          sleuth.enable = true;
        };

        comments.comment-nvim.enable = true;
        snippets.luasnip.enable = true;

        lsp = {
          enable = true;
          formatOnSave = true;
          trouble.enable = true;
          otter-nvim.enable = true;
          nvim-docs-view.enable = true;
        };

        languages = {
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;

          bash.enable = true;
          nu.enable = true;
          just.enable = true;

          nix.enable = dev.nix;

          clang.enable = dev.c;
          cmake.enable = dev.c;

          css.enable = dev.web;
          html.enable = dev.web;
          json.enable = dev.web;
          typescript.enable = dev.web;
          markdown.enable = dev.web;
          astro.enable = dev.web;
          astro.format.enable = false;

          python.enable = dev.python;

          typst.enable = dev.typst;

          rust = {
            enable = dev.rust;
            extensions.crates-nvim.enable = dev.rust;
          };
          toml.enable = dev.rust;

          csharp.enable = dev.dotnet;

          haskell.enable = dev.haskell;
        };

        visuals = {
          nvim-web-devicons.enable = true;
          nvim-cursorline.enable = true;
          rainbow-delimiters.enable = true;
          cinnamon-nvim.enable = true;
          highlight-undo.enable = true;
          cellular-automaton.enable = true;
        };

        statusline.lualine = {
          enable = true;
        };

        theme = ifCat {
          enable = true;
          name = "catppuccin";
          style = "mocha";
          transparent = false;
        };

        autocomplete.blink-cmp = {
          enable = true;
          setupOpts.cmdline.completion.ghost_text.enabled = false;
        };

        filetree.neo-tree = {
          enable = true;
          setupOpts = {
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
            filesystem.components.name = lib.generators.mkLuaInline ''
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

        tabline = {
          nvimBufferline = {
            enable = true;
            setupOpts.options = {
              numbers = "none";
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
              diagnostics_indicator = lib.generators.mkLuaInline ''
                function(count, level, diagnostics_dict, context)
                 local icon = level:match("error") and " " or " "
                 return " " .. icon .. count
                end
              '';
            };
          };
        };

        treesitter = {
          indent.enable = true;
        };

        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
        };

        telescope.enable = true;

        git = {
          enable = true;
          gitsigns.enable = true;
          gitsigns.codeActions.enable = false;
        };

        notify.nvim-notify.enable = true;

        terminal.toggleterm = {
          enable = true;
        };

        diagnostics.config.signs.text = {
          "[vim.diagnostic.severity.ERROR]" = "";
          "[vim.diagnostic.severity.WARN]" = "";
        };

        ui = {
          borders.enable = true;
          noice.enable = true;
          colorizer.enable = true;
          illuminate.enable = true;
          modes-nvim.enable = true;
        };

        opts = {
          mouse = "";
        };

        keymaps = [
          {
            key = "<leader><Tab>";
            mode = "n";
            silent = true;
            action = ":Neotree toggle reveal<CR>";
          }
        ];
      };
    };
  };
}
