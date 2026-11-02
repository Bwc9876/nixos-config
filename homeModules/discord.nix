{
  pkgs,
  config,
  lib,
  ...
}: let
  moonlightJson = pkgs.formats.json {};
in {
  options.cow.discord = {
    enable = lib.mkEnableOption "Discord + Moonlight + customizations";
  };

  options.programs.discord.moonlight = lib.mkOption {
    inherit (moonlightJson) type;
    default = {};
    description = "settings for Moonlight";
  };

  config = let
    conf = config.cow.discord;
  in
    lib.mkIf conf.enable (lib.mkMerge [
      {
        # Mostly stolen from Isabel: https://github.com/isabelroses/dotfiles/blob/b6c17688364b1cf785c4186d7a4a1d1a68ca59f3/home/isabel/discord.nix

        xdg.configFile."moonlight-mod/stable.json" = {
          force = true;
          source = moonlightJson.generate "moonlight-settings.json" config.programs.discord.moonlight;
        };

        home.file."${config.xdg.configHome}/${config.programs.discord.configName}/settings.json".force = true;

        programs.discord = {
          enable = true;
          package = pkgs.discord.override {withMoonlight = true;};
          settings = {
            SKIP_HOST_UPDATE = true;
            DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOURE_DOING = true;
            openasar = {
              setup = true;
              quickstart = true;
            };
            chromiumSwitches = {};
            IS_MAXIMIZED = false;
            IS_MINIMIZED = false;
            MINIMIZE_TO_TRAY = false;
            trayBalloonShown = false;
          };
        };
      }

      {
        programs.discord.moonlight = {
          extensions = {
            betterCodeblocks = true;
            betterEmbedsYT = true;
            betterUploadButton = true;
            cleanChatBar = {
              enabled = true;
              config.removedButtons = [
                "gift"
                "activity"
              ];
            };
            clearUrls = true;
            cloneExpressions = true;
            copyAvatarUrl = true;
            copyWebp = true;
            disableSentry = true;
            domOptimizer = true;
            doubleClickToJoin = true;
            experiments = true;
            freeMoji = false;
            freeScreenShare = true;
            imageViewer = true;
            inviteToNowhere = true;
            mentionAvatars = true;
            moonbase = true;
            nativeFixes = {
              enabled = pkgs.stdenv.hostPlatform.isLinux;
              config = {
                vaapiIgnoreDriverChecks = true;
                vaapiNvidia = true;
                linuxAutoscroll = true;
                zeroCopy = true;
                ignoreGpuBlocklist = true;
                waylandExplicitSync = true;
              };
            };
            noHideToken = true;
            noReplyPing = true;
            noReplyChainNag = true;
            noTrack = true;
            onePingPerDM = true;
            openExternally = true;
            pronouns = true;
            removeTitleBar = true;
            showReplyToSelf = true;
            svgEmbed = true;
            textReplacer = {
              enabled = true;
              config.patterns = {
                "://tiktok.com/" = "://tnktok.com/";
                "://vm.tiktok.com/" = "://vm.tnktok.com/";
                "://www.tiktok.com/" = "://www.tnktok.com/";
                "://twitter.com/" = "://vxtwitter.com/";
                "://instagram.com/" = "://oginstagram.com/";
                "://www.instagram.com/" = "://oginstagram.com/";
                "://reddit.com/" = "://vxreddit.com/";
                "://www.reddit.com/" = "://vxreddit.com/";
                "://x.com/" = "://vxtwitter.com/";
              };
            };
            trustAllDomains = true;
            unindent = true;
            volumeManipulator = true;
          };

          repositories = ["https://moonlight-mod.github.io/extensions-dist/repo.json"];
        };
      }
    ]);
}
