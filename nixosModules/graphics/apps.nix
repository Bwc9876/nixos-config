{pkgs, ...}: {
  # Desktop entry to launch htop
  home-manager.users.bean.xdg.dataFile."applications/htop.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Htop
    Exec=wezterm start --class="htop" htop
    Icon=htop
  '';

  environment.wordlist.enable = true;

  home-manager.users.bean.xdg.configFile = {
    # "Nickvision Cavalier/cava_config".text = ''
    #   [general]
    #   framerate = 144
    #   bars = 100
    #   autosens = 1
    #   sensitivity = 100
    #   [input]
    #   method = pulse
    #   [output]
    #   method = raw
    #   raw_target = /dev/stdout
    #   bit_format = 16bit
    #   channels = stereo
    #   [smoothing]
    #   monstercat = 1
    #   noise_reduction = 77
    # '';
    #
    # "Nickvision Cavalier/config.json".text =
    #   builtins.toJSON
    #   {
    #     ActiveProfile = 0;
    #     AreaMargin = 40;
    #     AreaOffsetX = 0;
    #     AreaOffsetY = 0;
    #     AutohideHeader = false;
    #     Autosens = true;
    #     BarPairs = 50;
    #     BgImageAlpha = 1;
    #     BgImageIndex = -1;
    #     BgImageScale = 1;
    #     Borderless = true;
    #     ColorProfiles = [
    #       {
    #         BgColors = ["#ff000000"];
    #         FgColors = ["#ffa51d2d" "#ffff7800" "#fff8e45c" "#ff2ec27e" "#ff1c71d8" "#ffdc8add"];
    #         Name = "Default";
    #         Theme = 1;
    #       }
    #     ];
    #     Direction = 1;
    #     FgImageAlpha = 1;
    #     FgImageIndex = -1;
    #     FgImageScale = 1;
    #     Filling = true;
    #     Framerate = 144;
    #     InnerRadius = 0.5;
    #     ItemsOffset = 0.1;
    #     ItemsRoundness = 0.5;
    #     LinesThickness = 5;
    #     Mirror = 0;
    #     Mode = 3;
    #     Monstercat = true;
    #     NoiseReduction = 0.77;
    #     ReverseMirror = false;
    #     ReverseOrder = true;
    #     Rotation = 0;
    #     Sensitivity = 10;
    #     SharpCorners = true;
    #     ShowControls = true;
    #     Stereo = true;
    #     WindowHeight = 300;
    #     WindowMaximized = true;
    #     WindowWidth = 500;
    #   };

    "htop/htoprc".text = ''
      htop_version=3.3.0
      config_reader_min_version=3
      fields=0 3 2 18 46 47 39 1
      hide_kernel_threads=1
      hide_userland_threads=0
      hide_running_in_container=0
      shadow_other_users=0
      show_thread_names=1
      show_program_path=0
      highlight_base_name=1
      highlight_deleted_exe=0
      shadow_distribution_path_prefix=0
      highlight_megabytes=1
      highlight_threads=1
      highlight_changes=0
      highlight_changes_delay_secs=5
      find_comm_in_cmdline=1
      strip_exe_from_cmdline=1
      show_merged_command=0
      header_margin=1
      screen_tabs=1
      detailed_cpu_time=0
      cpu_count_from_one=1
      show_cpu_usage=1
      show_cpu_frequency=0
      show_cpu_temperature=1
      degree_fahrenheit=0
      update_process_names=0
      account_guest_in_cpu_meter=1
      color_scheme=0
      enable_mouse=1
      delay=15
      hide_function_bar=0
      header_layout=two_67_33
      column_meters_0=System Hostname Date Clock Uptime Tasks CPU AllCPUs4 MemorySwap
      column_meter_modes_0=2 2 2 2 2 2 2 1 1
      column_meters_1=DiskIO DiskIO Blank NetworkIO NetworkIO
      column_meter_modes_1=2 3 2 2 3
      tree_view=0
      sort_key=46
      tree_sort_key=0
      sort_direction=-1
      tree_sort_direction=1
      tree_view_always_by_pid=0
      all_branches_collapsed=0
      screen:Main=PID PPID STATE NICE PERCENT_CPU PERCENT_MEM M_RESIDENT Command
      .sort_key=PERCENT_CPU
      .tree_sort_key=PID
      .tree_view_always_by_pid=0
      .tree_view=0
      .sort_direction=-1
      .tree_sort_direction=1
      .all_branches_collapsed=0
      screen:Tree=PID PPID PGRP PROCESSOR TTY USER SESSION Command
      .sort_key=PID
      .tree_sort_key=PID
      .tree_view_always_by_pid=0
      .tree_view=1
      .sort_direction=1
      .tree_sort_direction=1
      .all_branches_collapsed=0
      screen:I/O=PID PPID IO_READ_RATE IO_WRITE_RATE Command
      .sort_key=IO_RATE
      .tree_sort_key=PID
      .tree_view_always_by_pid=0
      .tree_view=0
      .sort_direction=-1
      .tree_sort_direction=1
      .all_branches_collapsed=0
    '';
  };

  environment.systemPackages = with pkgs; [
    # Office
    libreoffice-qt6

    ## Media
    obs-studio
    loupe
    inkscape
    lorien
    cavalier

    ## 3D
    # prusa-slicer
  ];
}
