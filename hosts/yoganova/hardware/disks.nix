{
  disk ? "/dev/disk/by-id/nvme-WD_PC_SN740_SDDPMQD-512G-1101_22452M447518",
  swapSize ? "16",
  ...
}: {
  disko.devices.disk = {
    nvme0n1 = {
      device = disk;
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
              mountOptions = ["defaults" "relatime" "umask=0077"];
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
              mountOptions = ["defaults" "noatime"];
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
  };
}
