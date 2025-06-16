{pkgs, ...}: {
  home-manager.users.bean.xdg.configFile."astro/config.json".text = builtins.toJSON {
    telemetry = {
      enabled = false;
      anonymousId = "";
      notifiedAt = "0";
    };
  };

  environment.systemPackages = with pkgs; [
    nodejs
    nodePackages.pnpm
    yarn
    # deno
  ];
}
