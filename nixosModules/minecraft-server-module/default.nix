{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkMerge
    mkIf
    mkDefault
    attrNames
    mapAttrsToList
    mapAttrs
    mkOption
    listToAttrs
    mkEnableOption
    filterAttrs
    ;
  inherit (lib.types)
    attrsOf
    listOf
    submodule
    port
    package
    str
    ;

  servers = filterAttrs (_: srv: srv.enable) config.spoon.mc-srv;

  container = pkgs.callPackage ./container.nix { };
  git-hook = pkgs.callPackage ./git-hook.nix { };
in
{
  options.spoon.mc-srv = mkOption {
    default = { };
    type =
      attrsOf
      <| submodule (
        { config, ... }:
        {
          options = {
            enable = mkEnableOption "this server" // {
              default = true;
            };
            autoStart = mkEnableOption "starting this server automatically at boot-up";
            hostPort = mkOption {
              type = port;
              description = "What port the server should listen on on the host";
            };
            image = mkOption {
              type = package;
              description = "The package to use";
              default = container;
            };
            extraPorts = mkOption {
              type = listOf str;
              default = [ ];
              description = "Extra ports to forward; `host:container`";
            };
          };

          config.extraPorts = [ "${toString config.hostPort}:25565" ];
        }
      );
    description = ''
      Minecraft server to run and create git deploy repos for. The git repos must be packwiz packs.

      Git usage: \
      {command}`git remote add deploy root@<host>:/etc/repos/<name>` \
      {command}`git push deploy HEAD:refs/heads/deploy`

      You can change HEAD here to be a branch, or whatever you want. You can also set up a remote in `/etc/repos/<name>` and pull to deploy.
    '';
  };

  config =
    let
      # TODO: healthcheck & sdnotify = healthy?
      # TODO: persist this
      mkGitRepo = name: {
        "repos/${name}/HEAD" = {
          text = "ref: refs/heads/deploy";
          mode = "644";
        };
        "repos/${name}/objects/.keep".text = "";
        "repos/${name}/refs/.keep".text = "";
        "repos/${name}/hooks/post-receive".source = "${git-hook}";
      };
      mkContainer =
        name:
        {
          autoStart,
          image,
          extraPorts,
          ...
        }:
        {
          inherit autoStart;
          image = "${image.imageName}:${image.imageTag}";
          imageStream = image;
          pull = "never";

          ports = extraPorts;
          volumes = [ "${name}:/srv" ];

          extraOptions = [
            "--tty" # Allow `podman attach <name>`
          ];
        };
    in
    mkIf (servers != { }) {
      virtualisation.oci-containers.backend = "podman";
      assertions = [
        {
          assertion = config.virtualisation.oci-containers.backend == "podman";
          message = "Spoon MC: we need `virtualisation.oci-containers.backend` to be podman";
        }
      ];
      environment.systemPackages = [ pkgs.git ];

      virtualisation.podman.autoPrune.enable = mkDefault true;

      cow.imperm.keep = [ "/etc/repos" ];
      environment.etc = mkMerge <| mapAttrsToList (name: _: mkGitRepo name) servers;

      virtualisation.oci-containers.containers = mapAttrs mkContainer servers;
      systemd.services =
        servers
        |> attrNames
        |> map (name: {
          name = "podman-${name}";
          value.unitConfig = {
            StartLimitIntervalSec = "5m";
            StartLimitBurst = 3;
            AssertPathExists = "/etc/repos/${name}/workdir/pack.toml";
          };
        })
        |> listToAttrs;
    };
}
