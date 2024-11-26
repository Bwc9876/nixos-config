{
  pkgs,
  inputs,
  ...
}: {
  # TODO: Nativify GMessages?

  environment.systemPackages = with pkgs; [
    vesktop
  ];

  home-manager.users.bean.xdg.configFile = {
    "vesktop/settings".source = "${inputs.self}/res/vencord/settings";
    "vesktop/themes".source = "${inputs.self}/res/vencord/themes";
  };
}
