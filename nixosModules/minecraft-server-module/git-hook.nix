{
  lib,
  stdenv,
  ghc,
  fetchurl,
  fetchFromGitHub,
  writeScript,
  nushell,
  dockerTools,
  mrpack-install,
  jre,
  runCommand,
  makeWrapper,
}: let
  inherit (lib) getExe;

  passthru = rec {
    unwrapped = stdenv.mkDerivation {
      name = "mc-srv-git-hook-hs-unwrapped";
      src = ./git-hook.hs;
      nativeBuildInputs = [ghc];
      buildCommand = "ghc $src -o $out -O2"; # TODO: other args?
    };

    # TODO: update these automatically? non-flake input and build?
    packwiz-installer = fetchurl {
      url = "https://github.com/packwiz/packwiz-installer-bootstrap/releases/download/v0.0.3/packwiz-installer-bootstrap.jar";
      sha256 = "sha256-qPuyTcYEJ46X9GiOgtPZGjGLmO/AjV2/y8vKtkQ9EWw=";
    };

    serverStarterJar = fetchurl {
      url = "https://github.com/neoforged/ServerStarterJar/releases/download/0.1.34/server.jar";
      sha256 = "sha256-H2tc/eUQ69HeNfoVqLHjgooheIJ1CIEPtzfPc4eAhLI=";
    };

    containerScript = writeScript "update-container-inner-script" ''
      #! ${getExe nushell}

      let versions = open /pack/pack.toml | get versions
      let GAMEVERSION = $versions.minecraft
      let loader = $versions
        | transpose name version
        | where name != minecraft
        | get 0 ${
        "" # TODO: assert exactly 1
      }
      let LOADER = $loader.name
      let LOADERVERSION = $loader.version

      # FIXME: only if game/loader outdated - save file with versions?
      mrpack-install server $LOADER --server-dir . --server-file server.jar --minecraft-version $GAMEVERSION --flavor-version $LOADERVERSION
      java -jar ${packwiz-installer} -g -s server file:///pack/pack.toml
      if ($LOADER == neoforge) { cp ${serverStarterJar} server.jar }
    '';

    mrpack-install' = mrpack-install.overrideAttrs {
      src = fetchFromGitHub {
        owner = "nothub";
        repo = "mrpack-install";
        rev = "480907b4ede34b6ecfa4cc1a6e5956083b40e0e6";
        hash = "sha256-eG2hXFUkY3Up3ikRo8JXQwsCruLj207tgFMkDv0/MOg=";
      };
      vendorHash = "sha256-SBlBkStfVAqfyDDs6subgBtH7M0BKg8mNSWQm8Cb9Qw=";
      doCheck = false; # Tries to do network IO
      postInstall = ""; # installing shell completion fails
    };

    updateContainer = dockerTools.buildLayeredImage {
      name = "packwiz-update-container";
      compressor = "none";
      maxLayers = 125;

      contents = [
        mrpack-install'
        jre
        dockerTools.caCertificates
        nushell
      ];

      extraCommands = ''
        mkdir tmp
        chmod 1777 tmp
      '';

      config.Entrypoint = ["${containerScript}"];
      config.WorkingDir = "/srv"; # This should be a bind mount
      config.Env = ["PATH=/bin:/lib/openjdk/bin"]; # FIXME: why don't we have /bin/java?
    };
  };
in
  with passthru;
    runCommand "mc-srv-git-hook" {
      inherit passthru;
      nativeBuildInputs = [makeWrapper];
    } "makeWrapper ${unwrapped} $out --set UPDATE_CONTAINER_PATH ${updateContainer}"
# TODO: does this need to make $out/bin?

