{
  target = "x86_64-linux";

  eval = {...}: {
    description = "Test / Example System";
    edition = "25.05";

    includeBaseMods = true;

    roles = ["latest-linux" "normalboot" "vm"];

    extraModules = [];
  };
}
