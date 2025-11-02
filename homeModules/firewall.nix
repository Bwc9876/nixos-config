{...}: {lib, ...}: {
  options.cow.firewall = {
    tcp = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [];
    };
    udp = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [];
    };
  };
}
