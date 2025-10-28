{...}: {
  services.syncthing = {
    enable = true;
    user = "bean";
    group = "users";
    openDefaultPorts = true;

    dataDir = "/home/bean";
    overrideFolders = false;
    overrideDevices = false;

    settings.options.urAccepted = -1;
  };
}
