{
  lib,
  flakelight,
  moduleArgs,
  ...
}:
lib.mapAttrs (_: v: v moduleArgs) (flakelight.importDir ./.)
