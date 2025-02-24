_: let
  partition = {
    boot = {
      size = "500M";
      type = "EF00";
      content = {
        type = "filesystem";
        format = "vfat";
        mountpoint = "/boot";
        mountOptions = ["umask=0077"];
      };
    };

    root."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=500M"
      ];
    };

    swap = {
      size = "16G";
      content = {
        type = "swap";
        randomEncryption = true;
        priority = 100;
      };
    };

    luks = {
      size = "100%";
      content = {
        type = "luks";
        name = "crypted";
        extraOpenArgs = [];
        settings = {
          keyFile = "/tmp/secret.key";
          allowDiscards = true;
        };
        content = {
          type = "lvm_pv";
          vg = "pool";
        };
      };
    };
  };

  nvme = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_2TB_S4J4NF0NC04658B";
    content = {
      type = "gpt";
      partitions = {
        inherit (partition) boot luks swap;
      };
    };
  };

  sda = {
    type = "disk";
    device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_2TB_S4X1NJ0NB04835M";
    content = {
      type = "gpt";
      partitions = {
        inherit (partition) luks;
      };
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
  disko.devices = {
    disk = {inherit nvme sda;};

    nodev = partition.root;

    lvm_vg.pool = {
      type = "lvm_vg";
      lvs = {inherit (volumes) persist home nix;};
    };
  };
}
