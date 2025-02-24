_: let
  ESP = {
    size = "500M";
    type = "EF00";
    content = {
      type = "filesystem";
      format = "vfat";
      mountpoint = "/boot";
      mountOptions = ["umask=0077"];
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
      # additionalKeyFiles = [ "/tmp/additionalSecret.key" ];
      content = {
        type = "lvm_pv";
        vg = "pool";
      };
    };
  };
in {
  disko.devices = {
    disk = {
      nvme = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_2TB_S4J4NF0NC04658B";
        content = {
          type = "gpt";
          partitions = {
            inherit ESP luks;
          };
        };
      };

      sda = {
        type = "disk";
        device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_2TB_S4X1NJ0NB04835M";
        content = {
          type = "gpt";
          partitions = {
            inherit luks;
          };
        };
      };
    };

    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = ["defaults"];
            };
          };
          home = {
            size = "10M";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/home";
            };
          };
          raw = {
            size = "10M";
          };
        };
      };
    };
  };
}
# {
#   nvme = {
#     type = "disk";
#     device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_2TB_S4J4NF0NC04658B";
#     content = {
#       type = "gpt";
#       partitions = {
#         ESP = {
#           type = "EF00";
#           size = "64M";
#           content = {
#             type = "filesystem";
#             format = "vfat";
#             mountpoint = "/boot";
#           };
#         };
#         swap = {
#           size = "12G";
#           content = {
#             type = "swap";
#             randomEncryption = true;
#           };
#         };
#         zroot = {
#           size = "100%";
#           content = {
#             type = "zfs";
#             pool = "rpool";
#           };
#         };
#       };
#     };
#   };
#   sda = {
#     type = "disk";
#     device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_2TB_S4X1NJ0NB04835M";
#     content = {
#       type = "gpt";
#       partitions = {
#         zroot = {
#           size = "100%";
#           content = {
#             type = "zfs";
#             pool = "rpool";
#           };
#         };
#       };
#     };
#   };
# }

