{ pkgs, myLib, ... }:
let
  device = "/dev/disk/by-id/wwn-0x60e08962daf1482688971d81ed377a85";

  partitionsCreateScript = ''
    set -euo pipefail
    test -b "${device}"

    parted -s "${device}" mklabel gpt
    parted -s "${device}" mkpart ESP fat32 1MiB 513MiB
    parted -s "${device}" set 1 esp on
    parted -s -a optimal "${device}" -- mkpart root ext4 513MiB 100%

    udevadm trigger --subsystem-match=block
    udevadm settle
  '';
  partitionsFormatScript = ''
    set -euo pipefail
    test -b "${device}-part1"
    test -b "${device}-part2"

    mkfs.vfat -F 32 -n ESP "${device}-part1"
    mkfs.ext4 -L nixos "${device}-part2"
  '';
  partitionsMountScript = ''
    set -euo pipefail
    mkdir -p /mnt
    mount -o noatime /dev/disk/by-partlabel/root /mnt
    mkdir -p /mnt/boot
    mount -o umask=0077 /dev/disk/by-partlabel/ESP /mnt/boot
  '';
in
{
  config = {
    fileSystems."/" = {
      device = "/dev/disk/by-partlabel/root";
      fsType = "ext4";
      options = [ "noatime" ];
    };
    fileSystems."/boot" = {
      device = "/dev/disk/by-partlabel/ESP";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };

    disks-create = myLib.utils.mkDiskScript pkgs "disks-create" partitionsCreateScript [
      pkgs.parted
      pkgs.util-linux
      pkgs.systemd
    ];

    disks-format = myLib.utils.mkDiskScript pkgs "disks-format" partitionsFormatScript [
      pkgs.dosfstools
      pkgs.e2fsprogs
    ];

    disks-mount = myLib.utils.mkDiskScript pkgs "disks-mount" partitionsMountScript [
      pkgs.coreutils
      pkgs.util-linux
    ];
  };
}
