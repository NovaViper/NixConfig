_:
let
  device-boot = "/dev/disk/by-id/nvme-WDC_PC_SN520_SDAPMUW-256G-1001_193463464112"; # 256 GB NVME drive
  device-media = "/dev/disk/by-id/nvme-PC611_NVMe_SK_hynix_1TB_NJA3N740810103U2F"; # 1 TB NVME drive
  device-docker = "/dev/disk/by-id/ata-WDC_WD5000AAKX-00U6AA0_WD-WCC2EM994761"; # 500 GB SATA drive
  device-sysbackup = "/dev/disk/by-id/ata-TOSHIBA_MQ01ABD100_Y679CGYGT"; # 1 TB SATA drive
  swapSize = "32";
in
{
  disko.devices.disk = {
    nvme0n1 = {
      device = device-boot;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            type = "EF00";
            size = "1G";
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
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/rootfs" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/swap" = {
                  mountpoint = "/.swapvol";
                  swap.swapfile.size = "${swapSize}G";
                };
              };
            };
          };
        };
      };
    };
    sda = {
      device = device-docker;
      type = "disk";
      content = {
        type = "gpt";
        partitions.containers = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes = {
              "/var/lib/containers" = {
                mountpoint = "/var/lib/containers";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
            };
          };
        };
      };
    };
    nvme1n1 = {
      device = device-media;
      type = "disk";
      content = {
        type = "gpt";
        partitions.media = {
          size = "100%";
          content = {
            type = "btrfs";
            mountpoint = "/mnt/media";
            mountOptions = [
              "compress=zstd"
              "noatime"
            ];
          };
        };
      };
    };
    sdb = {
      device = device-sysbackup;
      type = "disk";
      content = {
        type = "gpt";
        partitions.sysbackup = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            mountpoint = "/mnt/sysbackup";
            mountOptions = [
              "compress=zstd"
              "noatime"
            ];
          };
        };
      };
    };
  };
}
