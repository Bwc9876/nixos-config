{
	inputs,
	outputs,
	...
}: {
	system = "x86_64-linux";

	modules = [
		outputs.nixosModules.default
		inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x13-intel
		{
      home-manager.users.bean = {
        home.stateVersion = "26.11";
        xdg.userDirs.setSessionVariables = true;
        cow.dev.enable = false;
      };

			system.stateVersion = "26.11";

      users.users = let
        secureRoot = "/nix/persist/secure";
      in {
        bean.hashedPasswordFile = "${secureRoot}/hashed-passwd";
        root.hashedPasswordFile = "${secureRoot}/hashed-passwd";
      };

      cow = {
        base.enable = true;
        tty = {
          enable = true;
          autoLogin = true;
        };
        hm.enable = true;
        network.enable = true;
        cat.enable = true;
        bean = {
          enable = true;
          sudoer = true;
        };
        lanzaboote.enable = true;
        imperm.enable = true;
        disks = {
          enable = true;
          swap = true;
					luks = true;
        };
      };
		}
	];
}
