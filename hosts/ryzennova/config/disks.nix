{ pkgs, myLib, ... }:
let
  device = "/dev/disk/by-id/nvme-Sabrent_Rocket_Q_BE72071303B600060935";
  swapSize = "32"; # GiB

  partitionsCreateScript = ''
    parted -s "${device}" mklabel gpt
    parted -s "${device}" mkpart ESP fat32 1MiB 513MiB
    parted -s "${device}" set 1 esp on

    swapStartMiB=${myLib.utils.swapStartMiB device swapSize}
    parted -s -a optimal "${device}" -- mkpart root ext4 513MiB "''${swapStartMiB}MiB"
    parted -s -a optimal "${device}" -- mkpart swap linux-swap "''${swapStartMiB}MiB" 100%

    udevadm trigger --subsystem-match=block
    udevadm settle
  '';
  partitionsFormatScript = ''
    mkfs.vfat -n ESP "${device}-part1"
    mkfs.ext4 -L nixos "${device}-part2"
    mkswap -L swap "${device}-part3"
  '';
  partitionsMountScript = ''
    mount /dev/disk/by-partlabel/root /mnt
    mkdir -p /mnt/boot
    mount /dev/disk/by-partlabel/ESP /mnt/boot
  '';
in
{
  config = {
    fileSystems."/" = {
      device = "/dev/disk/by-partlabel/root";
      fsType = "ext4";
      options = [
        "defaults"
        "noatime"
      ];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-partlabel/ESP";
      fsType = "vfat";
      options = [
        "defaults"
        "relatime"
        "umask=0077"
      ];
    };

    swapDevices = [
      {
        device = "/dev/disk/by-partlabel/swap";
        discardPolicy = "both";
      }
    ];

    boot.resumeDevice = "/dev/disk/by-partlabel/swap";

    disks-create = myLib.utils.mkDiskScript pkgs "disks-create" partitionsCreateScript [
      pkgs.parted
      pkgs.util-linux
    ];

    disks-format = myLib.utils.mkDiskScript pkgs "disks-format" partitionsFormatScript [
      pkgs.dosfstools
      pkgs.e2fsprogs
      pkgs.util-linux
    ];

    disks-mount = myLib.utils.mkDiskScript pkgs "disks-mount" partitionsMountScript [
      pkgs.util-linux
    ];
  };
}
