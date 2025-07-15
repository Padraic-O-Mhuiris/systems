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
    device = "/dev/disk/by-id/nvme-PC_SN810_NVMe_WDC_1024GB_222320805140";
    content = {
      type = "gpt";
      partitions =
        {
          inherit (partition) boot;
        }
        // (partition.luks "vg-nvme");
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
      size = "300G";
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
      disk = {inherit nvme;};
      nodev = {
        root = {
          fsType = "tmpfs";
          mountpoint = "/";
          mountOptions = [
            "mode=0755"
            "uid=0"
            "gid=0"
            "size=2G"
          ];
        };
        tmp = {
          fsType = "tmpfs";
          mountpoint = "/tmp";
          mountOptions = [
            "mode=1777"
            "size=16G"
            "nodev"
            "nosuid"
            "exec"
          ];
        };
      };
      lvm_vg = {
        "vg-nvme" = {
          type = "lvm_vg";
          lvs = {inherit (volumes) persist swap home nix;};
        };
      };
    };
  };
}
