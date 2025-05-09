{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    alsa-utils
  ];

  nixpkgs.overlays = [
    (new: old: {
      swaynotificationcenter = old.swaynotificationcenter.overrideAttrs {
        postFixup = ''
          rm -r $out/share/systemd
          rm -r $out/lib/systemd
        '';
      };
    })
  ];

  home-manager.users.bean.services.swaync = {
    # TODO: Remove after checking
    enable = true;
    settings = {
      control-center-exclusive-zone = false;
      control-center-height = 1000;
      control-center-margin-bottom = 10;
      control-center-margin-left = 10;
      control-center-margin-right = 10;
      control-center-margin-top = 0;
      control-center-width = 800;
      fit-to-screen = false;
      hide-on-action = true;
      hide-on-clear = false;
      image-visibility = "when-available";
      keyboard-shortcuts = true;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      notification-icon-size = 64;
      notification-window-width = 500;
      positionX = "center";
      positionY = "top";
      script-fail-notify = true;
      scripts = {
        all = {
          exec = "${pkgs.nushell}/bin/nu ${../../res/notification.nu} ${../../res/notif-sounds}";
          urgency = ".*";
        };
      };
      timeout = 10;
      timeout-critical = 0;
      timeout-low = 5;
      transition-time = 200;
      widget-config = {
        dnd = {text = "Do Not Disturb";};
        label = {
          max-lines = 1;
          text = "Notification Center";
        };
        title = {
          button-text = "Clear All";
          clear-all-button = true;
          text = "Notification Center";
        };
      };
      widgets = ["title" "dnd" "notifications"];
    };
  };
}
