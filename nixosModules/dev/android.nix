{pkgs, ...}: {
  users.users.bean.extraGroups = ["kvm" "adbusers"];
  programs.adb.enable = true;
  services.udev.packages = [
    pkgs.android-udev-rules
  ];
}
