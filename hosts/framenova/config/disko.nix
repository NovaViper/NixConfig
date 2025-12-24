_:
let
  device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_1000GB_251637800361";
  swapSize = "32";
in
{
  disko.devices.disk = {
    nvme0n1 = {
      inherit device;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            size = "512M";
            type = "EF00";
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

          luksRoot = {
            end = "-${swapSize}G";
            content = {
              type = "luks";
              name = "cryptroot";
              settings = {
                allowDiscards = true;
                crypttabExtraOpts = [
                  "tpm2-device=auto"
                  "fido2-device=auto"
                  "token-timeout=10"
                ];
              };

              # Optional: keyfile backup (comment out if you don't want it)
              # keyFile = "/root/cryptroot.key";

              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                };
              };
            };
          };

          luksSwap = {
            size = "${swapSize}G";
            content = {
              type = "luks";
              name = "cryptswap";
              settings = {
                allowDiscards = true;
                crypttabExtraOpts = [
                  "tpm2-device=auto"
                  "fido2-device=auto"
                  "token-timeout=10"
                ];
              };
              content = {
                type = "swap";
                resumeDevice = true;
                randomEncryption = false;
              };
            };
          };
        };
      };
    };
  };
}
