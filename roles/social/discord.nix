{
  pkgs,
  inputs,
  ...
}: {
  # TODO: Nativify GMessages?

  environment.systemPackages = with pkgs; [
    vesktop
  ];

  home-manager.users.bean.home.file = {
    Vencord.source = "${inputs.self}/res/vencord";
    "VencordDesktop/VencordDesktop/settings".source = "${inputs.self}/res/vencord/settings";
    "VencordDesktop/VencordDesktop/themes".source = "${inputs.self}/res/vencord/themes";
  };
}
