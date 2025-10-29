{
  config,
  lib,
  pkgs,
  ...
}: {
  options.cow.qmplay2.enable = lib.mkEnableOption "QMPlay2 + customizations and yt-dlp";

  config = let
    mkQMPlayFile = lib.generators.toINI {};
    mkConfigDir = files:
      lib.mapAttrs' (
        name: value: lib.nameValuePair ("QMPlay2/" + name + ".ini") {text = mkQMPlayFile value;}
      )
      files;
  in
    lib.mkIf config.cow.qmplay2.enable {
      home.packages = with pkgs; [
        qmplay2
      ];

      xdg.configFile = mkConfigDir {
        ALSA.General = {
          AutoFindMultichnDev = true;
          Delay = 0.1;
          OutputDevice = "default";
          WriterEnabled = true;
        };
        AudioCD.AudioCD = {
          CDDB = true;
          CDTEXT = true;
        };
        AudioFilters = {
          General = {
            AVAudioFilter = false;
            BS2B = false;
            Compressor = false;
            Echo = false;
            Equalizer = false;
            PhaseReverse = false;
            SwapStereo = false;
            VoiceRemoval = false;
          };

          AVAudioFilter.Filters = "@ByteArray()";

          BS2B = {
            Fcut = 700;
            Feed = 4.5;
          };

          Compressor = {
            FastGainCompressionRatio = 0.9;
            OverallCompressionRatio = 0.6;
            PeakPercent = 90;
            ReleaseTime = 0.2;
          };

          Echo = {
            Delay = 500;
            Feedback = 50;
            Surround = false;
            Volume = 50;
          };

          Equalizer = {
            "-1" = 50;
            "0" = 50;
            "1" = 50;
            "2" = 50;
            "3" = 50;
            "4" = 50;
            "5" = 50;
            "6" = 50;
            "7" = 50;
            count = 8;
            maxFreq = 18000;
            minFreq = 200;
            nbits = 10;
          };

          PhaseReverse = {
            ReverseRight = false;
          };
        };
        CUVID.General = {
          DecodeMPEG4 = true;
          DeintMethod = 2;
          Enabled = true;
        };
        Chiptune.General = {
          DefaultLength = 180;
          GME = true;
          SIDPlay = true;
        };
        Extensions = {
          LastFM = {
            AllowBigCovers = true;
            DownloadCovers = true;
            Login = null;
            Password = null;
            UpdateNowPlayingAndScrobble = false;
          };

          MPRIS2.Enabled = true;

          YouTube = {
            ShowUserName = false;
            SortBy = 0;
            Subtitles = true;
          };
        };
        FFmpeg.General = {
          AllowExperimental = true;
          DecoderEnabled = true;
          DecoderVAAPIEnabled = true;
          DecoderVkVideoEnabled = true;
          DemuxerEnabled = true;
          ForceSkipFrames = false;
          HurryUP = true;
          LowresValue = 0;
          ReconnectNetwork = true;
          SkipFrames = true;
          TeletextPage = 0;
          TeletextTransparent = false;
          ThreadTypeSlice = false;
          Threads = 0;
          VAAPIDeintMethod = 1;
        };
        Modplug.General = {
          ModplugEnabled = true;
          ModplugResamplingMethod = 3;
        };
        Notify.General = {
          CustomBody = null;
          CustomMsg = false;
          CustomSummary = null;
          Enabled = false;
          ShowPlayState = true;
          ShowTitle = true;
          ShowVolume = true;
          Timeout = 5000;
        };
        Playlists.General = {
          M3U_enabled = true;
          XSPF_enabled = true;
        };
        PulseAudio.General = {
          Delay = 0.1;
          WriterEnabled = true;
        };
        QMPlay2 = {
          General = {
            AVBufferLocal = 100;
            AVBufferTimeNetwork = 500;
            AVBufferTimeNetworkLive = 5;
            AccurateSeek = 2;
            AllowOnlyOneInstance = false;
            AudioLanguage = null;
            AutoDelNonGroupEntries = false;
            AutoOpenVideoWindow = true;
            AutoRestoreMainWindowOnVideo = true;
            AutoUpdates = false;
            BackwardBuffer = 1;
            BlurCovers = true;
            Channels = 2;
            DisableSubtitlesAtStartup = false;
            DisplayOnlyFileName = false;
            EnlargeCovers = false;
            FallbackSubtitlesEncoding = "@ByteArray(UTF-8)";
            ForceChannels = 0;
            ForceSamplerate = false;
            HideArtistMetadata = false;
            IconsFromTheme = true;
            IgnorePlaybackError = false;
            KeepARatio = false;
            KeepSpeed = false;
            KeepSubtitlesDelay = false;
            KeepSubtitlesScale = false;
            KeepVideoDelay = false;
            KeepZoom = false;
            LastQMPlay2Path = "${pkgs.qmplay2}/bin";
            LeftMouseTogglePlay = 0;
            LongSeek = 30;
            MaxVol = 100;
            MiddleMouseToggleFullscreen = false;
            Mute = false;
            NoCoversCache = false;
            OutputFilePath = "/home/bean/Downloads";
            PlayIfBuffered = 1.75;
            Renderer = "opengl";
            RepeatMode = 0;
            ResamplerFirst = true;
            RestoreAVSState = false;
            RestoreRepeatMode = false;
            RestoreVideoEqualizer = false;
            Samplerate = 48000;
            SavePos = false;
            ShortSeek = 5;
            ShowBufferedTimeOnSlider = true;
            ShowCovers = true;
            ShowDirCovers = true;
            Silence = true;
            SkipPlaylistsWithinFiles = true;
            SkipYtDlpUpdate = false;
            StillImages = false;
            StoreARatioAndZoom = false;
            StoreUrlPos = true;
            Style = "kvantum";
            SubtitlesLanguage = null;
            SyncVtoA = true;
            TrayNotifiesDefault = false;
            TrayVisible = true;
            UnpauseWhenSeeking = false;
            UpdateVersion = pkgs.qmplay2.version;
            Version = "@ByteArray(${pkgs.qmplay2.version})";
            VideoFilters = "0FPS Doubler";
            VolumeL = 100;
            VolumeR = 100;
            WheelAction = true;
            WheelSeek = true;
            screenshotFormat = ".png";
            screenshotPth = "/home/bean/Pictures/Screenshots";
          };

          ApplyToASS = {
            ApplyToASS = false;
            ColorsAndBorders = true;
            FontsAndSpacing = false;
            MarginsAndAlignment = false;
          };

          Deinterlace = {
            Auto = true;
            AutoParity = true;
            Doubler = true;
            ON = true;
            SoftwareMethod = ''Yadif 2x'';
            TFF = false;
          };

          MainWidget = {
            AlwaysOnTop = false;
            CompactViewDockWidgetState = ''@ByteArray()'';
            DockWidgetState = ''@ByteArray()'';
            FullScreenDockWidgetState = ''@ByteArray()'';
            Geometry = ''@Rect(226 151 1805 1203)'';
            IsCompactView = false;
            KeepDocksSize = false;
            TabPositionNorth = false;
            WidgetsLocked = true;
            isMaximized = true;
            isVisible = true;
          };

          OSD = {
            Alignment = 4;
            Background = false;
            BackgroundColor = ''@Variant(\0\0\0\x43\x1\x88\x88\0\0\0\0\0\0\0\0)'';
            Bold = false;
            Enabled = true;
            FontName = "Sans Serif";
            FontSize = 32;
            LeftMargin = 0;
            Outline = 1.5;
            OutlineColor = ''@Variant(\0\0\0\x43\x1\xff\xff\0\0\0\0\0\0\0\0)'';
            RightMargin = 0;
            Shadow = 1.5;
            ShadowColor = ''@Variant(\0\0\0\x43\x1\xff\xff\0\0\0\0\0\0\0\0)'';
            Spacing = 0;
            TextColor = ''@Variant(\0\0\0\x43\x1\xff\xff\xaa\xaa\xff\xffUU\0\0)'';
            VMargin = 0;
          };

          OpenGL = {
            BypassCompositor = false;
            OnWindow = false;
            VSync = true;
          };

          Proxy = {
            Host = null;
            Login = false;
            Password = ''@ByteArray()'';
            Port = 80;
            Use = false;
            User = null;
          };

          ReplayGain = {
            Album = false;
            Enabled = false;
            Preamp = 0;
            PreventClipping = true;
          };

          SettingsWidget.Geometry = ''@Rect(395 263 2212 1308)'';

          Subtitles = {
            Alignment = 7;
            Background = true;
            BackgroundColor = ''@Variant(\0\0\0\x43\x1\x88\x88\0\0\0\0\0\0\0\0)'';
            Bold = false;
            FontName = "Fira Code";
            FontSize = 24;
            LeftMargin = 15;
            Outline = 1;
            OutlineColor = ''@Variant(\0\0\0\x43\x1\xff\xff\0\0\0\0\0\0\0\0)'';
            RightMargin = 15;
            Shadow = 0.5;
            ShadowColor = ''@Variant(\0\0\0\x43\x1\xff\xff\0\0\0\0\0\0\0\0)'';
            Spacing = 2;
            TextColor = ''@Variant(\0\0\0\x43\x1\xff\xff\xff\xff\xff\xff\xff\xff\0\0)'';
            VMargin = 15;
          };

          VideoAdjustment = {
            Brightness = 0;
            Contrast = 0;
            Hue = 0;
            Negative = 0;
            Saturation = 0;
            Sharpness = 0;
          };

          Vulkan = {
            AlwaysGPUDeint = true;
            BypassCompositor = true;
            Device = "@ByteArray()";
            ForceVulkanYadif = false;
            HDR = false;
            HQScaleDown = false;
            HQScaleUp = false;
            VSync = 1;
            YadifSpatialCheck = true;
          };

          YtDl = {
            CookiesFromBrowser = null;
            CookiesFromBrowserEnabled = false;
            CustomPath = "${pkgs.yt-dlp}/bin/yt-dlp";
            CustomPathEnabled = true;
            DefaultQuality = null;
            DefaultQualityEnabled = false;
            DontAutoUpdate = true;
          };
        };
        QPainterSW.General.Enabled = true;
        Subtitles.General = {
          Classic_enabled = true;
          SRT_enabled = true;
          Sub_max_s = 5;
          Use_mDVD_FPS = true;
        };
        VideoFilters.FPSDoubler = {
          MaxFPS = 29.99;
          MinFPS = 21;
          OnlyFullScreen = true;
        };
        Visualizations = {
          General = {
            RefreshTime = 17;
          };

          FFTSpectrum = {
            LimitFreq = 20000;
            Size = 8;
          };

          SimpleVis = {
            SoundLength = 17;
          };
        };
        XVideo.General = {
          Enabled = false;
          UseSHM = false;
        };
      };
    };
}
