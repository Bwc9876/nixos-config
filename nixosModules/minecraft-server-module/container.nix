# To install modded server:
# mrpack-install <modrinth-slug> --server-dir <dir> --server-file server.jar
# TODO: create volume with nixery? - or init image with mrpack-install that also does initialFiles?

/*
  For vanilla server:
  { mc-srv-container, minecraft-server }:
  mc-srv-container.override {
    name = "mc-vanilla-latest";
    serverJar = minecraft-server.src.outPath;
    memory = "2G";
  }
*/

{
  name ? "mc-srv", # Name of the image
  ports ? [ "25565/tcp" ], # List of ports, not sure what this actually does
  env ? {
    LD_LIBRARY_PATH = lib.makeLibraryPath [ udev ]; # TODO: more customization?
  }, # Environment variables

  # These only have an effect if `entrypoint` is default
  serverJar ? "server.jar", # Can also be eg "${minecraft-server.src}"
  memory ? "8G", # -Xmx and -Xms; this default is for modded

  # List of strings; what gets run in the container
  entrypoint ? [
    "${jre}/bin/java"

    # Aikar's flags
    "-XX:+UseG1GC"
    "-XX:+ParallelRefProcEnabled"
    "-XX:MaxGCPauseMillis=200"
    "-XX:+UnlockExperimentalVMOptions"
    "-XX:+DisableExplicitGC"
    "-XX:+AlwaysPreTouch"
    "-XX:G1NewSizePercent=30"
    "-XX:G1MaxNewSizePercent=40"
    "-XX:G1HeapRegionSize=8M"
    "-XX:G1ReservePercent=20"
    "-XX:G1HeapWastePercent=5"
    "-XX:G1MixedGCCountTarget=4"
    "-XX:InitiatingHeapOccupancyPercent=15"
    "-XX:G1MixedGCLiveThresholdPercent=90"
    "-XX:G1RSetUpdatingPauseTimePercent=5"
    "-XX:SurvivorRatio=32"
    "-XX:+PerfDisableSharedMem"
    "-XX:MaxTenuringThreshold=1"
    "-Dusing.aikars.flags=https://mcflags.emc.gs"
    "-Daikars.new.flags=true"

    "-Xms${memory}"
    "-Xmx${memory}"

    "-jar"
    "${serverJar}"
  ],

  lib,
  dockerTools,
  udev,
  jre, # This is only used if `entrypoint` is left default
}:
let
  inherit (lib) genAttrs const mapAttrsToList;
in
dockerTools.streamLayeredImage {
  inherit name;
  tag = "latest";

  maxLayers = 125; # A bit of wiggle room below 127 (the limit?)

  extraCommands = ''
    mkdir tmp
    chmod 1777 tmp
  '';

  # TODO: run as non-root?
  # - can't touch store
  # - but might make file perms weird
  # - store will get reset if container run with --rm
  config = {
    Entrypoint = entrypoint;
    Cmd = [ "nogui" ];
    Volumes."/srv" = { }; # Server files
    WorkingDir = "/srv";
    ExposedPorts = genAttrs ports (const { });
    Env = mapAttrsToList (n: val: "${n}=${val}") env;
  };
}
