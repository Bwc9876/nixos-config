{pkgs, ...}: {
  # TODO: Nativify GMessages?

  environment.systemPackages = with pkgs; [
    vesktop
  ];

  home-manager.users.bean.xdg.configFile = {
    "vesktop/settings/quickCss.css".text = "";
    "vesktop/settings/settings.json".text = builtins.toJSON {
      autoUpdate = false;
      autoUpdateNotification = false;
      cloud = {
        authenticated = false;
        settingsSync = false;
        settingsSyncVersion = 1719252668865;
        url = "https://api.vencord.dev/";
      };
      disableMinSize = false;
      enableReactDevtools = false;
      enabledThemes = [];
      frameless = false;
      macosTranslucency = false;
      notifications = {
        logLimit = 50;
        position = "bottom-right";
        timeout = 5000;
        useNative = "always";
      };
      notifyAboutUpdates = false;
      plugins = {
        AlwaysTrust = {
          domain = true;
          enabled = true;
          file = true;
        };
        AnonymiseFileNames = {
          anonymiseByDefault = true;
          enabled = true;
          method = 0;
          randomisedLength = 7;
        };
        AutomodContext.enabled = true;
        BadgeAPI.enabled = true;
        BetterGifAltText.enabled = true;
        BetterSettings = {
          disableFade = true;
          eagerLoad = true;
          organizeMenu = true;
        };
        ClearURLs.enabled = true;
        CommandsAPI.enabled = true;
        ContextMenuAPI.enabled = true;
        CopyUserURLs.enabled = true;
        CrashHandler.enabled = true;
        Experiments = {
          enabled = true;
          toolbarDevMenu = false;
        };
        FixYoutubeEmbeds.enabled = true;
        FriendsSince.enabled = true;
        MemberCount = {
          enabled = true;
          memberList = true;
          toolTip = true;
        };
        MemberListDecoratorsAPI.enabled = true;
        MessageAccessoriesAPI.enabled = true;
        MessageDecorationsAPI.enabled = true;
        MessageEventsAPI.enabled = true;
        NoOnboardingDelay.enabled = true;
        NoPendingCount = {
          enabled = true;
          hideFriendRequestsCount = true;
          hideMessageRequestsCount = false;
          hidePremiumOffersCount = true;
        };
        NoProfileThemes.enabled = true;
        NoReplyMention = {
          enabled = true;
          inverseShiftReply = false;
          shouldPingListed = true;
          userList = "1234567890123445,1234567890123445";
        };
        NoServerEmojis = {
          shownEmojis = "onlyUnicode";
        };
        NoTrack = {
          disableAnalytics = true;
          enabled = true;
        };
        NoticesAPI.enabled = true;
        OpenInApp = {
          enabled = true;
          epic = true;
          spotify = true;
          steam = true;
          tidal = true;
        };
        PictureInPicture.enabled = true;
        PlatformIndicators = {
          badges = true;
          colorMobileIndicator = true;
          enabled = true;
          list = true;
          messages = true;
        };
        Settings = {
          enabled = true;
          settingsLocation = "aboveActivity";
        };
        ShikiCodeblocks = {
          enabled = true;
          theme = "https://raw.githubusercontent.com/shikijs/shiki/0b28ad8ccfbf2615f2d9d38ea8255416b8ac3043/packages/shiki/themes/dark-plus.json";
          useDevIcon = "GREYSCALE";
        };
        Summaries = {
          summaryExpiryThresholdDays = 3;
        };
        SupportHelper.enabled = true;
        TypingTweaks.enabled = true;
        UserSettingsAPI.enabled = true;
        VoiceChatDoubleClick.enabled = true;
        VoiceDownload.enabled = true;
        WatchTogetherAdblock.enabled = true;
        WebContextMenus = {
          addBack = true;
        };
        WebScreenShareFixes.enabled = true;
        WhoReacted.enabled = true;
      };
      themeLinks = ["https://catppuccin.github.io/discord/dist/catppuccin-mocha-green.theme.css"];
      transparent = false;
      useQuickCss = true;
      winCtrlQ = false;
      winNativeTitleBar = false;
    };
  };
}
