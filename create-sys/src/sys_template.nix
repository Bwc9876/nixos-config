{
  target = "__TARGET__";
  extraOverlays = [];

  eval = {inputs, ...}: {
    description = "__DESCRIPTION__";

    edition = "__EDITION__";

    includeBaseMods = __INCL_BASE_MODS__;

    roles = [__ROLES__];
    extraModules = [
      __HARDWARE_MOD__
      __HARDWARE_CONFIG__
    ];
  };
}
