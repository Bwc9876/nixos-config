{pkgs, ...}: {
  home-manager.users.bean.programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    mutableExtensionsDir = false;
    package = pkgs.vscodium;

    extensions = with pkgs.vscode-extensions; [
      # Theme
      (pkgs.catppuccin-vsc.override {
        accent = "green";
        boldKeywords = true;
        italicComments = true;
        italicKeywords = true;
        extraBordersEnabled = false;
        workbenchMode = "default";
        bracketMode = "rainbow";
        colorOverrides = {};
        customUIColors = {};
      })
      catppuccin.catppuccin-vsc-icons

      # Nix
      bbenoist.nix
      kamadorueda.alejandra

      # Markdown
      yzhang.markdown-all-in-one
      bierner.markdown-mermaid
      davidanson.vscode-markdownlint

      # Rust
      rust-lang.rust-analyzer
      tamasfe.even-better-toml

      # C / C++
      ms-vscode.cpptools
      twxs.cmake

      # Java
      redhat.java

      # Typescript / Javascript
      denoland.vscode-deno
      yoavbls.pretty-ts-errors
      dbaeumer.vscode-eslint
      esbenp.prettier-vscode

      # Astro
      astro-build.astro-vscode
      unifiedjs.vscode-mdx

      # Misc. Web
      bradlc.vscode-tailwindcss

      # .NET
      ms-dotnettools.csharp
      ms-dotnettools.vscode-dotnet-runtime

      # Python
      ms-python.python
      ms-python.vscode-pylance
      ms-python.black-formatter
      wholroyd.jinja

      # XML
      redhat.vscode-xml

      # Spelling / Grammar
      yzhang.dictionary-completion
      tekumara.typos-vscode

      # GitHub
      github.vscode-pull-request-github
      github.vscode-github-actions

      # Misc.
      skellock.just
      thenuprojectcontributors.vscode-nushell-lang
      fill-labs.dependi
      zhwu95.riscv
      redhat.vscode-yaml
      ms-vsliveshare.vsliveshare
      leonardssh.vscord
    ];

    userSettings = {
      "window.zoomLevel" = 2;
      "telemetry.telemetryLevel" = "off";
      "update.mode" = "manual";
      "update.showReleaseNotes" = false;
      "editor.fontFamily" = "monospace";
      "editor.detectIndentation" = true;
      "editor.multiCursorModifier" = "ctrlCmd";
      "editor.minimap.enabled" = false;
      "editor.fontSize" = 16;
      "terminal.integrated.fontSize" = 16;
      "workbench.colorTheme" = "Catppuccin Mocha";
      "workbench.iconTheme" = "catppuccin-mocha";
      "workbench.startupEditor" = "none";
      "workbench.welcomePage.walkthroughs.openOnInstall" = false;
      "terminal.integrated.fontFamily" = "monospace";
      "terminal.integrated.smoothScrolling" = true;
      "explorer.compactFolders" = false;
      "explorer.confirmDelete" = false;
      "explorer.confirmDragAndDrop" = false;
      "git.openRepositoryInParentFolders" = "never";
      "extensions.autoUpdate" = false;
      "extensions.ignoreRecommendations" = true;
      "javascript.updateImportsOnFileMove.enabled" = "always";
      "typescript.updateImportsOnFileMove.enabled" = "always";
      "githubPullRequests.pullBranch" = "never";
      "vscord.app.name" = "Visual Studio Code";
      "vscord.status.idle.disconnectOnIdle" = true;
      "vscord.behaviour.suppressNotifications" = true;
      "material-icon-theme.folders.color" = "#546E7B";
      "redhat.telemetry.enabled" = false;
      "rust-analyzer.server.path" = "${pkgs.rust-analyzer}/bin/rust-analyzer";
      "prettier.prettierPath" = "${pkgs.nodePackages.prettier}/lib/node_modules/prettier";
      "rust-analyzer.cargo.allTargets" = false;
      "rust-analyzer.hover.actions.references.enable" = true;
      "dotnetAcquisitionExtension.enableTelemetry" = false;

      "[json][yaml][javascript][typescript][javascriptreact][typescriptreact][css][scss][less][tailwindcss][html][astro]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      "[python]" = {
        "editor.defaultFormatter" = "ms-python.black-formatter";
      };

      "[rust]" = {
        "editor.defaultFormatter" = "rust-lang.rust-analyzer";
      };

      "[nix]" = {
        "editor.defaultFormatter" = "kamadorueda.alejandra";
      };

      "[markdown]" = {
        "editor.defaultFormatter" = "DavidAnson.vscode-markdownlint";
      };
    };
  };
}
