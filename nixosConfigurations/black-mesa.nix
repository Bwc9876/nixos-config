{
  inputs,
  outputs,
  ...
}: {
  system = "x86_64-linux";

  modules = [
    outputs.nixosModules.default
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.spoon.nixosModules.black-mesa
    (
      {config, ...}: {
        home-manager.users.bean.home.stateVersion = "25.05";
        system.stateVersion = "25.05";
        networking.hostName = "black-mesa";

        powerManagement.cpuFreqGovernor = "performance";

        boot.initrd.availableKernelModules = [
          "nvme"
          "xhci_pci"
          "ahci"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];
        boot.kernelModules = ["kvm-amd"];
        boot.extraModulePackages = [];

        hardware.enableRedistributableFirmware = true;

        # Other disks handled by cow.disks
        fileSystems."/mnt/storage" = {
          device = "/dev/sda1";
          fsType = "btrfs";
        };

        users.users = let
          secureRoot = "/nix/persist/secure";
        in {
          bean.hashedPasswordFile = "${secureRoot}/hashed-passwd";
          root = {
            openssh.authorizedKeys.keys = [config.cow.bean.pubkey];
            hashedPasswordFile = "${secureRoot}/hashed-passwd";
          };
        };

        home-manager.users.bean.cow = {
          sync.enable = true;
          dev.enable = false;
        };

        cow = {
          bean.sudoer = true;
          lanzaboote.enable = true;
          ssh-server.enable = true;
          role-desktop.enable = true;
          gaming.enable = true;
          imperm.enable = true;
          disks = {
            enable = true;
            partition-prefix = "cow-bm";
            swap = false;
            luks = true;
          };
        };
      }
    )
    {
      # Bingus!
      imports = [inputs.bingus.nixosModules.default];

      cow.imperm.keep = [
        "/var/lib/bingus"
      ];

      services.bingus-bot = {
        enable = true;
        tokenFile = "/nix/persist/secure/bingus-token";
        replyChannels = [
          1295245646542143489
          1479180106508271697
        ];
      };
    }
    (
      {
        config,
        pkgs,
        lib,
        ...
      }: {
        # Self hosted stuff

        cow = {
          tranquil = {
            enable = true;
            domainName = "tranquil.bwc9876.dev";
            envFile = "/nix/persist/secure/tranquil.env";
          };
          tangled = {
            knot = {
              enable = true;
              hostname = "knot.bwc9876.dev";
              gitUser = "gurt";
            };
            spindle = {
              enable = true;
              hostname = "spindle.bwc9876.dev";
            };
          };
          imperm.keep = ["/var/lib/acme"];
        };

        networking.firewall.allowedTCPPorts = [
          80
          443
        ];

        services.nginx = {
          enable = true;

          recommendedTlsSettings = true;
          recommendedBrotliSettings = true;
          recommendedOptimisation = true;
          recommendedGzipSettings = true;
          recommendedProxySettings = true;
          experimentalZstdSettings = true;

          # TODO: HTTP Challenge instead?
          virtualHosts."knot.bwc9876.dev" = {
            addSSL = true;
            acmeRoot = null; # Doing DNS challenges
            useACMEHost = "bwc9876.dev";
          };
          virtualHosts."tranquil.bwc9876.dev" = {
            addSSL = true;
            acmeRoot = null; # DNS
            useACMEHost = "bwc9876.dev";
          };
          virtualHosts."*.tranquil.bwc9876.dev" = {
            locations."/".proxyPass = "http://127.0.0.1:${builtins.toString config.services.tranquil-pds.settings.server.port}";
            addSSL = true;
            acmeRoot = null; # DNS
            useACMEHost = "tranquil.bwc9876.dev";
          };
          virtualHosts."spindle.bwc9876.dev" = {
            addSSL = true;
            acmeRoot = null; # DNS
            useACMEHost = "bwc9876.dev";
          };
        };

        services.tranquil-pds.settings.email = {
          from_address = lib.strings.join "@" [
            "beanpds"
            (lib.strings.join "." [
              "gmail"
              "com"
            ])
          ];
          from_name = "Bean PDS";
        };

        programs.msmtp = {
          enable = true;
          accounts.default = {
            auth = true;
            # ssshhhhh
            host = "smtp.gmail.com";
            user = lib.strings.join "@" [
              "beanpds"
              (lib.strings.join "." [
                "gmail"
                "com"
              ])
            ];
            from = lib.strings.join "@" [
              "beanpds"
              (lib.strings.join "." [
                "gmail"
                "com"
              ])
            ];
            passwordeval = "cat /nix/persist/secure/smtp-pass";
            port = 587;
            tls = true;
          };
        };

        security.acme = {
          acceptTerms = true;
          defaults = {
            email = "ben@bwc9876.dev";
          };
          certs."tranquil.bwc9876.dev" = {
            domain = "*.tranquil.bwc9876.dev";
            reloadServices = ["nginx"];
            group = config.services.nginx.group;
            dnsProvider = "porkbun";
            environmentFile = "/nix/persist/secure/porkbun.env";
          };
          certs."bwc9876.dev" = {
            domain = "*.bwc9876.dev";
            reloadServices = [
              "nginx"
            ];
            group = config.services.nginx.group;
            dnsProvider = "porkbun";
            environmentFile = "/nix/persist/secure/porkbun.env";
          };
        };
      }
    )
    {
      # WOL
      systemd.network.links."79-eth-wol" = {
        matchConfig = {
          Type = "ether";
          Driver = "!veth";
          Virtualization = "false";
        };
        linkConfig = {
          WakeOnLan = "magic";
          NamePolicy = "keep kernel database onboard slot path";
          AlternativeNamesPolicy = "database onboard slot path mac";
          MACAddressPolicy = "persistent";
        };
      };
    }
    (
      {lib, ...}: {
        virtualisation.podman.enable = true;
        # spoon.mc-srv.cobblemon.enable = lib.mkForce false;
        spoon.yggdrasil.enable = lib.mkForce false;
        spoon.yggdrasil.config.Listen = lib.mkForce [];
        cow.imperm.keep = ["/var/lib/containers"];
      }
    )
  ];
}
