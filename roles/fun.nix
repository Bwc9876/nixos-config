{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    hyfetch
    lolcat
    cowsay
    kittysay
    toilet
    gay
    pipes-rs
  ];

  home-manager.users.bean.xdg.configFile."hyfetch.json".source = "${inputs.self}/res/hyfetch.json";
}
