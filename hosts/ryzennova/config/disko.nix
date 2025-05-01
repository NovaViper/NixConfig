{
  disk ? "/dev/disk/by-id/nvme-Sabrent_Rocket_Q_BE72071303B600060935",
  swapSize ? "32",
  inputs,
  ...
}:
{
  imports = with inputs; [ disko.nixosModules.disko ];

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
  };
}
