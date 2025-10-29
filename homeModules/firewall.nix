{lib}: {
  options.cow.firewall = {
    tcp = { type = lib.types.listOf lib.types.int; };
    udp = { type = lib.types.listOf lib.types.int; };
  };
}
