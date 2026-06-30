_:
# Based on https://github.com/leierx/homelab/blob/4bf3227cb0c28410839eabd3f56ddf79bef3101c/nixos/disko.nix
let
  device-boot = "/dev/disk/by-id/nvme-WDC_PC_SN520_SDAPMUW-256G-1001_193463464112"; # 256 GB NVME drive
  swapSize = "32";

  dataDisks = {
    disk1.device = "/dev/disk/by-id/wwn-0x5000c500b5b75c48";
    disk2.device = "/dev/disk/by-id/wwn-0x5000c500604f2a8b";
    disk3.device = "/dev/disk/by-id/wwn-0x50014ee2b1b0c4c9";
    disk4.device = "/dev/disk/by-id/wwn-0x50014ee25c5afeae";
    disk5.device = "/dev/disk/by-id/wwn-0x50014ee25c469b56";
    disk6.device = "/dev/disk/by-id/wwn-0x50014ee206f187e1";
    disk7.device = "/dev/disk/by-id/wwn-0x50014ee20705da2f";
  };

  mkZfsDisk = name: value: {
    type = "disk";
    device = value.device;

    content = {
      type = "gpt";
      partitions = {
        zfs = {
          size = "100%";
          content = {
            type = "zfs";
            pool = "pool0";
          };
        };
      };
    };
  };

in
{
  disko.devices = {
    disk = {
      nvme0n1 = {
        device = device-boot;
        type = "disk";
        name = "nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              type = "EF00";
              size = "512M";
              priority = 1;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                  "relatime"
                  "umask=0077"
                ];
              };
            };
            root = {
              #size = "100%";
              end = "-${swapSize}G";
              priority = 2;
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = [
                  "defaults"
                  "noatime"
                ];
              };
            };
            swap = {
              size = "100%";
              priority = 3;
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true;
              };
            };
          };
        };
      };
    }
    // builtins.mapAttrs mkZfsDisk dataDisks;

    zpool.pool0 = {
      type = "zpool";
      mode = "raidz2"; # 2-disk fault tolerance, RAID6
      options = {
        ashift = "12"; # Force 4K sector size for better performance on modern drives
      };
      rootFsOptions = {
        canmount = "off"; # Do not mount the pool root itself
        mountpoint = "none";
        compression = "zstd"; # Enable compression for better storage efficiency
        atime = "off"; # Don't update file access timestamps
        xattr = "sa"; # Store extended attributes more efficiently
        acltype = "posixacl"; # Enable POSIX ACL support
      };

      datasets = {
        # NOTE: Here is the reason why we use options.moountpoint instead of just
        # mountpoint: https://github.com/nix-community/disko/issues/581#issuecomment-2260602290
        storage = {
          type = "zfs_fs";
          options.mountpoint = "/storage";
        };
        services = {
          type = "zfs_fs";
          options.mountpoint = "/storage/services";
        };

        media = {
          type = "zfs_fs";
          options.mountpoint = "/storage/media";
        };

        backups = {
          type = "zfs_fs";
          options.mountpoint = "/storage/backups";
        };
      };
    };
  };
}
