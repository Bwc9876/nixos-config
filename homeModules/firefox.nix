{...}: {
  lib,
  pkgs,
  config,
  ...
}: let
  package = pkgs.firefox-devedition;
in {
  options.cow.firefox.enable =
    lib.mkEnableOption "enable Firefox with customizations"
    // {
      default = config.cow.gdi.enable;
    };

  config = lib.mkIf config.cow.firefox.enable {
    cow.imperm.keep = [".mozilla"];

    programs.firefox = {
      inherit package;
      enable = true;

      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DisableSetDesktopBackground = true;
        DontCheckDefaultBrowser = true;
        AppAutoUpdate = false;
        DNSOverHTTPS.Enabled = true;
        ShowHomeButton = true;
        DisplayBookmarksToolbar = "always";
        DisableProfileImport = true;
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        OfferToSaveLoginsDefault = false;
        OverrideFirstRunPage = "";
        NoDefaultBookmarks = true;
        PasswordManagerEnabled = false;
        SearchBar = "unified";
        EncryptedMediaExtensions = true;

        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
          EmailTracking = true;
        };

        Preferences = let
          lock = val: {
            Value = val;
            Status = "locked";
          };
        in {
          # General
          "browser.aboutConfig.showWarning" = lock false;
          "media.eme.enabled" = lock true; # Encrypted Media Extensions (DRM)
          "layout.css.prefers-color-scheme.content-override" = lock 0;
          "browser.startup.page" = 3; # Restore previous session
          "toolkit.telemetry.server" = lock "";

          # New Tab
          "browser.newtabpage.activity-stream.showSponsored" = lock false;
          "browser.newtabpage.activity-stream.system.showSponsored" = lock false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = lock false;
          "browser.newtabpage.activity-stream.feeds.topsites" = lock false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock false;
          "browser.newtabpage.activity-stream.showWeather" = lock false;
          "browser.newtabpage.activity-stream.system.showWeather" = lock false;
          "browser.newtabpage.activity-stream.feeds.weatherfeed" = lock false;
          "browser.newtabpage.activity-stream.feeds.telemetry" = lock false;
          "browser.newtabpage.activity-stream.telemetry" = lock false;
          "browser.newtabpage.activity-stream.telemetry.structuredIngestion.endpoint" = lock "";
          "browser.newtabpage.pinned" = lock [];
          "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.havePinned" = lock "";
          "browser.urlbar.suggest.weather" = lock false;
          "browser.urlbar.quicksuggest.scenario" = lock "offline";
          "browser.urlbar.suggest.quicksuggest.nonsponsored" = lock false;
          "browser.urlbar.suggest.quicksuggest.sponsored" = lock false;

          # Devtools
          "devtools.theme" = lock "dark";
          "devtools.dom.enabled" = lock true;
          "devtools.command-button-rulers.enabled" = lock true;
          "devtools.command-button-measure.enabled" = lock true;
          "devtools.command-button-screenshot.enabled" = lock true;
          "devtools.toolbox.host" = lock "right";
          "devtools.webconsole.persistlog" = lock true;
          "devtools.webconsole.timestampMessages" = lock true;

          # Privacy
          "dom.private-attribution.submission.enabled" = lock false;
          "privacy.globalprivacycontrol.enabled" = lock true;

          # ML
          "browser.ml.enable" = lock false;
          "browser.ml.linkPreview.enabled" = lock false;
          "browser.ml.pageAssist.enabled" = lock false;
          "browser.ml.chat.enabled" = lock false;
          "browser.ml.chat.menu" = lock false;
          "browser.ml.chat.page" = lock false;
          "browser.ml.chat.shortcuts" = lock false;
          "browser.ml.chat.sidebar" = lock false;
        };

        Extensions.Install =
          map (x: "https://addons.mozilla.org/firefox/downloads/latest/${x}/latest.xpi")
          (
            [
              # Appearance
              "firefox-color"
              "material-icons-for-github"

              # Security / Privacy
              "facebook-container"

              ## Ads / Youtube
              "ublock-origin"
              "consent-o-matic"
              "sponsorblock"

              # Information
              "flagfox"
              "awesome-rss"
              "identfavicon-quantum"
              "margin"

              # Devtools
              "react-devtools"
              "open-graph-preview-and-debug"
              "wave-accessibility-tool"
              "styl-us"
            ]
            ++ (lib.optional config.cow.keepassxc.enable "keepassxc-browser")
          );

        ExtensionSettings."*" = {
          default_area = "menupanel";
        };
      };
      profiles.dev-edition-default = {
        extensions = {
          force = true;
          settings = {
            "sponsorBlocker@ajay.app".settings.alreadyInstalled = true;
            "uBlock0@raymondhill.net".settings.selectedFilterLists = [
              "ublock-filters"
              "ublock-badware"
              "ublock-privacy"
              "ublock-unbreak"
              "ublock-quick-fixes"
            ];
            # Stylus
            "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}".settings = {
              dbInChromeStorage = true; # required se DB is stored in state.js
              updateOnlyEnabled = true;
              patchCsp = true;
              instantInject = true;
            };
          };
        };
        search = {
          force = true;
          default = "ddg";
          privateDefault = "ddg";
          engines = let
            mkEngineForceFavicon = aliases: queryUrl: iconUrl: {
              definedAliases = aliases;
              icon = iconUrl;
              urls = [{template = queryUrl;}];
            };
            mkEngine = aliases: queryUrl: iconExt: (mkEngineForceFavicon aliases queryUrl (
              let
                noPath = lib.strings.concatStrings (
                  lib.strings.intersperse "/" (lib.lists.take 3 (lib.strings.splitString "/" queryUrl))
                );
              in "${noPath}/favicon.${iconExt}"
            ));
            mkModrinth = aliases: type: mkEngine aliases "https://modrinth.com/discover/${type}?q={searchTerms}" "ico";
          in {
            # Dev
            "GitHub Repos" =
              mkEngineForceFavicon ["@gh" "@github"]
              "https://github.com/search?type=repositories&q={searchTerms}"
              "https://github.githubassets.com/favicons/favicon-dark.svg";
            "SourceGraph" = mkEngine [
              "@sg"
              "@sourcegraph"
            ] "https://sourcegraph.com/search?q={searchTerms}" "png";

            ## Web
            "MDN Web Docs" = mkEngine [
              "@mdn"
            ] "https://developer.mozilla.org/en-US/search?q={searchTerms}" "ico";
            "Web.Dev" =
              mkEngineForceFavicon ["@webdev" "@lighthouse"] "https://web.dev/s/results?q={searchTerms}"
              "https://www.gstatic.com/devrel-devsite/prod/vc7080045e84cd2ce1faf7f7a3876037748d52d088e5100df2e949d051a784791/web/images/favicon.png";
            "Can I Use" = mkEngineForceFavicon [
              "@ciu"
              "@baseline"
            ] "https://caniuse.com/?search={searchTerms}" "https://caniuse.com/img/favicon-128.png";
            "NPM" = mkEngine ["@npm"] "https://www.npmx.dev/search?q={searchTerms}" "ico";
            "Iconify" = mkEngine [
              "@iconify"
              "@icons"
            ] "https://icon-sets.iconify.design/?query={searchTerms}" "ico";
            "Astro" = mkEngineForceFavicon [
              "@astro"
            ] "https://a.stro.cc/{searchTerms}" "https://docs.astro.build/favicon.svg";
            "Porkbun" = mkEngine ["@porkbun"] "https://porkbun.com/checkout/search?q={searchTerms}" "ico";
            "Http.Cat" = mkEngine ["@cat" "@hcat" "@httpcat"] "https://http.cat/{searchTerms}" "ico";

            ## Rust
            "Crates.io" = mkEngine [
              "@crates"
              "@cratesio"
              "@cargo"
            ] "https://crates.io/search?q={searchTerms}" "ico";
            "Rust Docs" =
              mkEngineForceFavicon ["@rust" "@rustdocs" "@ruststd"]
              "https://doc.rust-lang.org/std/index.html?search={searchTerms}"
              "https://doc.rust-lang.org/static.files/favicon-2c020d218678b618.svg";
            "Docsrs" = mkEngine ["@docsrs"] "https://docs.rs/releases/search?query={searchTerms}" "ico";

            ## Python
            "PyPI" = mkEngineForceFavicon [
              "@pypi"
              "@pip"
            ] "https://pypi.org/search/?q={searchTerms}" "https://pypi.org/static/images/favicon.35549fe8.ico";

            ## .NET
            "NuGet" = mkEngine ["@nuget"] "https://www.nuget.org/packages?q={searchTerms}" "ico";

            ## Linux Stuff
            "Kernel Docs" = mkEngine [
              "@lnx"
              "@linux"
              "@kernel"
            ] "https://www.kernel.org/doc/html/latest/search.html?q={searchTerms}" "ico";
            "Arch Wiki" = mkEngine [
              "@aw"
              "@arch"
            ] "https://wiki.archlinux.org/index.php?title=Special%3ASearch&search={searchTerms}" "ico";
            "Nerd Fonts" =
              mkEngineForceFavicon ["@nf" "@nerdfonts"] "https://www.nerdfonts.com/cheat-sheet?q={searchTerms}"
              "https://www.nerdfonts.com/assets/img/favicon.ico";

            ### Haskell
            "Hoogle Base" = mkEngine [
              "@h"
              "@hoogle"
            ] "https://hoogle.haskell.org/?scope=package%3Abase&hoogle={searchTerms}" "png";
            "Hoogle All" = mkEngine [
              "@ha"
              "@hoogall"
            ] "https://hoogle.haskell.org/?hoogle={searchTerms}" "png";

            ### Nix
            "Nix Packages" = mkEngine [
              "@nixpkgs"
            ] "https://search.nixos.org/packages?channel=unstable&size=500&query={searchTerms}" "png";
            "NixOS Options" = mkEngine [
              "@nixos"
            ] "https://search.nixos.org/options?channel=unstable&size=500&query={searchTerms}" "png";
            "NixOS Wiki" = mkEngine ["@nixwiki"] "https://nixos.wiki/index.php?search={searchTerms}" "png";
            "Home Manager Options" =
              mkEngineForceFavicon ["@hm"]
              "https://home-manager-options.extranix.com/?release=master&query={searchTerms}"
              "https://home-manager-options.extranix.com/images/favicon.png";
            "Noogle" = mkEngine [
              "@noogle"
              "@nixlib"
            ] "https://noogle.dev/q?limit=100&term={searchTerms}" "png";
            "SourceGraph Nix" =
              mkEngine ["@sgn" "@yoink"]
              "https://sourcegraph.com/search?q=lang:Nix+-repo:NixOS/*+-repo:nix-community/*+{searchTerms}"
              "png";
            "Nixpkgs Issues" =
              mkEngineForceFavicon ["@nixissues"]
              "https://github.com/NixOS/nixpkgs/issues?q=sort%3Aupdated-desc+is%3Aissue+is%3Aopen+{searchTerms}"
              "https://github.githubassets.com/favicons/favicon-dark.svg";
            "NixVim Options" =
              mkEngineForceFavicon ["@nixvim"]
              "https://nix-community.github.io/nixvim/search/?option_scope=0&query={searchTerms}"
              "https://nix-community.github.io/nixvim/search/favicon.ico";

            # Media
            "youtube" = mkEngine ["@yt"] "https://www.youtube.com/results?search_query={searchTerms}" "ico";
            "Spotify" =
              mkEngineForceFavicon ["@sp" "@spotify"] "https://open.spotify.com/search/{searchTerms}"
              "https://open.spotifycdn.com/cdn/images/favicon16.1c487bff.png";
            "Netflix" = mkEngine ["@nfx"] "https://www.netflix.com/search?q={searchTerms}" "ico";
            "IMDb" = mkEngine ["@imdb"] "https://www.imdb.com/find?q={searchTerms}" "ico";

            # Minecraft
            "Modrinth" = mkModrinth ["@mr"] "mods";
            "Modrinth Resource Packs" = mkModrinth ["@mrr"] "resourcepacks";
            "Modrinth Data Packs" = mkModrinth ["@mrd"] "datapacks";

            # Misc
            "Firefox Add-ons" = mkEngine [
              "@addons"
            ] "https://addons.mozilla.org/en-US/firefox/search/?q={searchTerms}" "ico";
            "Urban Dictionary" = mkEngine [
              "@ud"
              "@urban"
            ] "https://www.urbandictionary.com/define.php?term={searchTerms}" "ico";
            "Google Translate" = mkEngine [
              "@translate"
            ] "https://translate.google.com/?sl=auto&tl=en&text={searchTerms}&op=translate" "ico";

            # Overrides
            "History".metaData.alias = "@h";
            "Bookmarks".metaData.alias = "@b";
            "Tabs".metaData.alias = "@t";
            "bing".metaData.hidden = true;
            "amazondotcom-us".metaData.alias = "@amz";
            "google".metaData.alias = "@g";
            "wikipedia".metaData.alias = "@w";
            "ddg".metaData.alias = "@ddg";
          };
        };
      };
    };
  };
}
