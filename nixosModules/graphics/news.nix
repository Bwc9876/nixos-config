{pkgs, ...}: let
  yt-feed = id: {
    url = "https://www.youtube.com/feeds/videos.xml?channel_id=" + id;
    tags = [
      "!"
      "youtube"
    ];
  };
  yt-subs = [
    "UCa8W2_uf81Ew6gYuw0VPSeA" # Juxtaposed
    "UCMiyV_Ib77XLpzHPQH_q0qQ" # Veronica Explains
    "UC7_YxT-KID8kRbqZo7MyscQ" # Markiplier
    "UCUMwY9iS8oMyWDYIe6_RmoA" # No Boilerplate
    "UCRC6cNamj9tYAO6h_RXd5xA" # RTGame
    "UCYIwBA7mwDWnrckXs7gt76Q" # Snapcube
    "UCCHruaQlOKPHTl8iOPGDjFg" # Snapcube 2 (VODs)
    "UCL7DDQWP6x7wy0O6L5ZIgxg" # 2ndJerma
    "UC9z7EZAbkphEMg0SP7rw44A" # carykh
    "UCpmvp5czsIrQHsbqya4-6Jw" # Chad Chad
    "UC0e3QhIYukixgh5VVpKHH9Q" # Code Bullet
    "UCfPUcG3oCmXEYgdFuwlFh8w" # Dingo Doodles
    "UCsBjURrPoezykLs9EqgamOA" # Fireship
    "UCGwu0nbY2wSkW8N-cghnLpA" # Jaiden Animations
    "UClBNmmlREy6BD8PSTFBDyQg" # Kan Gao
    "UCm8EsftbfNzSiRHzc7I59KQ" # Kevin Faang
    "UCtHaxi4GTYDpJgMSGy7AeSw" # Michael Reeves
    "UCXq2nALoSbxLMehAvYTxt_A" # The Grumps
    "UCBa659QWEk1AI4Tg--mrJ2A" # Tom Scott
    "UCFLwN7vRu8M057qJF8TsBaA" # UpIsNotJump
    "UCPsSoOCRNIj-eo2UbXfcdAw" # xen 42
    "UCYBbrJH2H6tmQZ7VHyA_esA" # Saltydkdan
    "UCBZb-2BHvUtZ-WzrEj16lug" # Raicuparta
    "UCPDXXXJj9nax0fr0Wfc048g" # Dropout
    "UC8EYr_ArKMKaxfgRq-iCKzA" # WindowsG Electronics
    "UCJXa3_WNNmIpewOtCHf3B0g" # LaurieWired
  ];
in {
  environment.systemPackages = with pkgs; [
    w3m
    rdrview
  ];

  home-manager.users.bean = {
    xdg.dataFile."applications/newsboat.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=newsboat
      Icon=newsboat
    '';

    programs.newsboat = {
      enable = true;
      browser = ''"${../../res/news-open.nu} %u"'';

      # notify-program ${../res/news-notify.nu}

      extraConfig = ''
        confirm-mark-feed-read no
        confirm-mark-all-feeds-read no
        wrap-scroll yes
        text-width 90

        color listnormal color8 default
        color listnormal_unread default default
        color listfocus black green
        color listfocus_unread black green bold
      '';

      queries = {
        "Youtube" = "tags # \"youtube\"";
      };

      urls =
        [
          {
            title = "Outer Wilds Mods";
            url = "https://outerwildsmods.com/feed.xml";
            tags = [
              "dev"
              "outer-wilds"
            ];
          }
          # {
          #   title = "Philly Voice";
          #   url = "https://www.phillyvoice.com/feed/section/news/";
          #   tags = ["local"];
          # }
          # {
          #   title = "ChesCo";
          #   url = "https://www.mychesco.com/feed";
          #   tags = ["local"];
          # }
          {
            title = "Mobius Digital";
            url = "https://www.mobiusdigitalgames.com/news/feed";
            tags = ["outer-wilds"];
          }
          {
            title = "NixOS Blog";
            url = "https://nixos.org/blog/feed.xml";
            tags = [
              "dev"
              "linux"
              "nixos"
            ];
          }
          {
            title = "Linux Kernel Releases";
            url = "https://www.kernel.org/feeds/kdist.xml";
            tags = [
              "dev"
              "linux"
            ];
          }
          {
            title = "Linux Weekly News";
            url = "https://lwn.net/headlines/newrss";
            tags = [
              "dev"
              "linux"
            ];
          }
          {
            title = "Linux Kernel Planet";
            url = "https://planet.kernel.org/rss20.xml";
            tags = [
              "dev"
              "linux"
            ];
          }
          {
            title = "Free Desktop Planet";
            url = "https://planet.freedesktop.org/atom.xml";
            tags = [
              "dev"
              "linux"
            ];
          }
          {
            title = "KDE Blog";
            url = "https://blogs.kde.org/index.xml";
            tags = [
              "dev"
              "linux"
            ];
          }
          {
            title = "Cloudflare Blog";
            url = "https://blog.cloudflare.com/rss";
            tags = [
              "dev"
              "security"
            ];
          }
          {
            title = "Rust Blog";
            url = "https://blog.rust-lang.org/feed.xml";
            tags = [
              "dev"
              "rust"
            ];
          }
          {
            title = "Tauri Blog";
            url = "https://tauri.app/blog/rss.xml";
            tags = [
              "dev"
              "rust"
            ];
          }
          {
            title = "Node.js Blog";
            url = "https://nodejs.org/en/feed/blog.xml";
            tags = [
              "dev"
              "web"
            ];
          }
          {
            title = "V8 Blog";
            url = "https://v8.dev/blog.atom";
            tags = [
              "dev"
              "web"
            ];
          }
          {
            title = "Vite Blog";
            url = "https://vitejs.dev/blog.rss";
            tags = [
              "dev"
              "web"
            ];
          }
          {
            title = "React Blog";
            url = "https://react.dev/rss.xml";
            tags = [
              "dev"
              "web"
            ];
          }
          {
            title = "Astro JS";
            url = "https://astro.build/rss.xml";
            tags = [
              "dev"
              "web"
            ];
          }
          {
            title = "W3C Blog";
            url = "https://www.w3.org/blog/feed/";
            tags = [
              "dev"
              "web"
            ];
          }
          {
            title = "Mozilla Blog";
            url = "https://blog.mozilla.org/en/feed/";
            tags = [
              "dev"
              "web"
            ];
          }
          {
            title = "Mozilla Nightly Blog";
            url = "https://blog.nightly.mozilla.org/feed/";
            tags = [
              "dev"
              "web"
            ];
          }
          {
            title = "Mozilla Developer Network";
            url = "https://developer.mozilla.org/en-US/blog/rss.xml";
            tags = [
              "dev"
              "web"
            ];
          }
          {
            title = "Chrome Dev Blog";
            url = "https://developer.chrome.com/static/blog/feed.xml";
            tags = [
              "dev"
              "web"
            ];
          }
          {
            title = "Webkit Blog";
            url = "https://webkit.org/feed/";
            tags = [
              "dev"
              "web"
            ];
          }
          {
            title = "GitHub Blog";
            url = "https://github.blog/feed/";
            tags = [
              "dev"
              "github"
            ];
          }
          {
            title = "GitHub Status";
            url = "https://www.githubstatus.com/history.rss";
            tags = [
              "dev"
              "github"
            ];
          }
          {
            title = "Veronica Explains";
            url = "https://vkc.sh/feed/";
            tags = [
              "linux"
              "personal-blog"
            ];
          }
          {
            title = "Tom Scott Newsletter";
            url = "https://www.tomscott.com/updates.xml";
            tags = ["personal-blog"];
          }
          {
            title = "Dave Eddy";
            url = "https://blog.daveeddy.com/rss.xml";
            tags = ["personal-blog"];
          }
          {
            title = "Dylan Beattie";
            url = "https://dylanbeattie.net/feed.xml";
            tags = ["personal-blog"];
          }
          {
            title = "Xe Iaso";
            url = "https://xeiaso.net/blog.rss";
            tags = ["personal-blog"];
          }
          {
            title = "Anil Dash";
            url = "https://www.anildash.com/feed.xml";
            tags = ["personal-blog"];
          }
          {
            title = "HiDeoo";
            url = "https://hideoo.dev/notes/rss.xml";
            tags = ["personal-blog"];
          }
          {
            title = "Kerkour";
            url = "https://kerkour.com/feed.xml";
            tags = ["personal-blog"];
          }
          {
            title = "Avis";
            url = "https://avris.it/blog.atom";
            tags = ["personal-blog"];
          }
          {
            title = "Scripting News";
            url = "http://scripting.com/rss.xml";
            tags = ["personal-blog"];
          }
          {
            title = "XKCD";
            url = "https://xkcd.com/rss.xml";
            tags = ["personal-blog"];
          }
          {
            title = "Framework Laptop";
            url = "https://frame.work/blog.rss";
            tags = ["hardware"];
          }
          {
            title = "Ars Technica";
            url = "https://arstechnica.com/feed/";
            tags = ["tech"];
          }
          {
            title = "Lobste";
            url = "https://lobste.rs/rss";
            tags = ["tech"];
          }
        ]
        ++ (map yt-feed yt-subs);
    };
  };
}
