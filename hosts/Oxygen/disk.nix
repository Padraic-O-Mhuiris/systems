{inputs, ...}: let
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
            vg = name;
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
        // (partition.luks "vg-nvme");
    };
  };

  sda = {
    type = "disk";
    device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_2TB_S4X1NJ0NB04835M";
    content = {
      type = "gpt";
      partitions = partition.luks "vg-sda";
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
      size = "100%";
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
    devices = {
      disk = {inherit nvme sda;};
      nodev = {
        root = {
          fsType = "tmpfs";
          mountpoint = "/";
          mountOptions = [
            # If not included root ("/") will be 777 and ssh will not work under strict mode
            "mode=0755"
            "uid=0"
            "gid=0"
            "size=2G"
          ];
        };
      };
      lvm_vg = {
        "vg-nvme" = {
          type = "lvm_vg";
          lvs = {inherit (volumes) persist swap home;};
        };
        "vg-sda" = {
          type = "lvm_vg";
          lvs = {inherit (volumes) nix;};
        };
      };
    };
  };
}
