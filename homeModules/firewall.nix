{...}: {lib, ...}: {
  options.cow.firewall = {
    tcp = lib.mkOption {type = lib.types.listOf lib.types.int;};
    udp = lib.mkOption {type = lib.types.listOf lib.types.int;};
  };
}
