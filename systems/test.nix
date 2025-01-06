{
  target = "x86_64-linux";
  extraOverlays = [];

  eval = {...}: {
    description = "Test / Example System";
    edition = "25.05";

    includeBaseMods = true;

    roles = ["latest-linux" "normalboot" "imperm"];
    extraModules = [];
  };
}
