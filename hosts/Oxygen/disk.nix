{
  inputs,
  lib,
  ...
}: let
  partition = {
    boot = {
      size = "500M";
      type = "EF00";
      content = {
        type = "filesystem";
        format = "vfat";
        mountpoint = "/boot";
        mountOptions = ["defaults"];
      };
    };

    luks = name: {
      "${name}" = {
        size = "100%";
        content = {
          type = "luks";
          inherit name;
          passwordFile = "/tmp/secret.key";
          settings.allowDiscards = true;
          content = {
            type = "lvm_pv";
            vg = "pool";
          };
        };
      };
    };
  };

  nvme = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_2TB_S4J4NF0NC04658B";
    content = {
      type = "gpt";
      partitions =
        {
          inherit (partition) boot;
        }
        // (partition.luks "crypted-nvme");
    };
  };

  sda = {
    type = "disk";
    device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_2TB_S4X1NJ0NB04835M";
    content = {
      type = "gpt";
      partitions = partition.luks "crypted-sda";
    };
  };

  volumes = {
    persist = {
      size = "10G";
      content = {
        type = "filesystem";
        format = "ext4";
        mountpoint = "/persist";
      };
    };

    swap = {
      size = "16G";
      content = {
        type = "swap";
        randomEncryption = true;
        priority = 100;
      };
    };

    home = {
      size = "500G";
      content = {
        type = "filesystem";
        format = "ext4";
        mountpoint = "/home";
      };
    };

    nix = {
      size = "100%";
      content = {
        type = "filesystem";
        format = "ext4";
        mountpoint = "/nix";
      };
    };
  };
in {
  imports = [inputs.disko.nixosModules.disko];

  disko = {
    imageBuilder.extraConfig = {
      boot.initrd.preDeviceCommands = ''
        echo -n 'abc123' > /tmp/secret.key
      '';
      # disko.devices.disk = {
      #   nvme.content.partitions.crypted-nvme.content.askPassword = true;
      #   sda.content.partitions.crypted-sda.content.askPassword = true;
      # };
    };
    devices = {
      disk = {inherit nvme sda;};

      nodev = {
        root = {
          fsType = "tmpfs";
          mountpoint = "/";
          mountOptions = [
            "size=250M"
          ];
        };
      };

      lvm_vg.pool = {
        type = "lvm_vg";
        lvs = {inherit (volumes) swap persist home nix;};
      };
    };
  };

  virtualisation.vmVariantWithDisko = {
    virtualisation.fileSystems."/persist".neededForBoot = true;
  };
}
