{...}: {
  users.users.bean.extraGroups = ["kvm" "adbusers"];
  programs.adb.enable = true;
}
