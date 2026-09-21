{
  lib,
  inputs,
  config,
  outputs,
  flakelight,
  moduleArgs,
  pkgsFor,
  ...
}:
let
  inherit (lib) warn mkOption;
  inherit (lib)
    defaultTo
    elemAt
    fileContents
    last
    length
    mapNullable
    pathExists
    pipe
    trace
    zipAttrsWith
    ;

  hackPkgs =
    system:
    assert warn
      "Ellis's repl: current system `${system}` not supported by current flake, proceeding anyway"
      true;
    import inputs.nixpkgs {
      inherit system;
      inherit (config.nixpkgs) config;
      overlays = config.withOverlays ++ [ config.packageOverlay ];
    };
  getPkgs = system: pkgsFor.${system} or (hackPkgs system);

  hosts = inputs.self.nixosConfigurations;

  hostname = if pathExists /etc/hostname then fileContents /etc/hostname else null;
  thisHost = pipe hostname [
    (mapNullable (hn: hosts.${hn} or null))
    (defaultTo {
      config = { };
      options = { };
    })
  ];

  zipper =
    name: vals:
    if length vals == 1 then elemAt vals 0 else trace "repl: multiple defs for ${name}" (last vals);

  # First line is to prevent the first line getting shifted
  banner = ''
    You're using:
                                ▄
    ██████ ▄▄    ▄▄    ▄▄  ▄▄▄▄ ▀ ▄▄▄▄   ▄█████  ▄▄▄   ▄▄▄  ▄▄
    ██▄▄   ██    ██    ██ ███▄▄  ███▄▄   ██     ██▀██ ██▀██ ██
    ██▄▄▄▄ ██▄▄▄ ██▄▄▄ ██ ▄▄██▀  ▄▄██▀   ▀█████ ▀███▀ ▀███▀ ██▄▄▄

    ███  ██ ▄▄ ▄▄ ▄▄   █████▄  ██████ █████▄ ██
    ██ ▀▄██ ██ ▀█▄█▀   ██▄▄██▄ ██▄▄   ██▄▄█▀ ██
    ██   ██ ██ ██ ██   ██   ██ ██▄▄▄▄ ██     ██████

    Stuff in scope:
    - nixpkgs `lib` functions eg `zipAttrsWith`
    - all hosts eg `black-mesa`
    - config from the current host directly eg `programs.firefox.enable`
    - the values `config`, `options`, `pkgs`, `lib`
    - The values `self`, `flakelight`, `moduleArgs`, `outputs`, `inputs`
  '';
in
{
  outputs.repl = trace banner zipAttrsWith zipper [
    lib
    thisHost.config
    hosts
    {
      pkgs = hosts.${hostname}.pkgs or (getPkgs builtins.currentSystem);
      inherit (thisHost) config options;
      inherit (inputs) self;
      inherit
        lib
        flakelight
        moduleArgs
        outputs
        inputs
        ;
    }
  ];
}
