{...}: {
  config,
  lib,
  ...
}: {
  options.cow.firewall.openForUsers = lib.mkEnableOption "Opening firewall from HM configs for all users";

  config = lib.mkIf (config.cow.hm.enable
    && config.cow.firewall.openForUsers) (
    let
      getFirewall = lib.attrByPath ["cow" "firewall"] {};
      allFirewalls = map getFirewall (builtins.attrValues config.home-manager.users);
      selectPortType = ty: builtins.foldl' (acc: elem: acc ++ elem.${ty}) [];
    in {
      networking.firewall = {
        allowedTCPPorts = selectPortType "tcp" allFirewalls;
        allowedUDPPorts = selectPortType "udp" allFirewalls;
      };
    }
  );
}
