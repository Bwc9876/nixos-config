{
  config,
  lib,
  pkgs,
  ...
}: {
  options.cow.ddhx = {
    enable = lib.mkEnableOption "ddhx hex editor + customizations";
    package = lib.mkPackageOption pkgs "ddhx" {};

    # TODO: This is silly :P
    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Settings to place in config file. See CONFIGURATION section of ddhx.1 for docs";
      default = {
        "mirror-cursor" = "on";
      };
      example = {
        "mirror-cursor" = "on";
        "columns" = "auto";
      };
    };

    colors = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Set colors of different elements";
      default = {
        "cursor" = "green:black";
        "mirror" = "red:black";
        "selection" = "black:blue";
        "zero" = "gray";
      };
      example = {
        cursor = "blue:white";
      };
    };

    binds = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Set keybinds";
      default = {
        ":" = "menu";
        "i" = "change-mode";
      };
    };
  };

  config = lib.mkIf config.cow.ddhx.enable {
    home.packages = [
      config.cow.ddhx.package
    ];

    xdg.configFile."ddhx/.ddhxrc".text = let
      inherit (config.cow.ddhx) settings colors binds;
      mkEntries = word:
        lib.mapAttrsToList (k: v:
          (
            if word != null
            then word + " "
            else ""
          )
          + k
          + " "
          + v);
      entries = (mkEntries null settings) ++ (mkEntries "color" colors) ++ (mkEntries "bind" binds);
    in
      lib.concatLines entries;
  };
}
