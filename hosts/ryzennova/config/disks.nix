{ pkgs, ... }:
# Based on https://github.com/Baitinq/nixos-config/blob/979313a290981f3c9f62fb5c6f180e87e331ac5f/hardware/pc/disks.nix
let
  device = "/dev/disk/by-id/nvme-Sabrent_Rocket_Q_BE72071303B600060935";
  swapSize = "32"; # GiB

  partitionsCreateScript = ''
    parted -s "${device}" mklabel gpt
    parted -s "${device}" mkpart ESP fat32 1MiB 513MiB
    parted -s "${device}" set 1 esp on

    # Compute an explicit end of the root partition in MiB, which is the total
    # size of the disk minus the swap size in GiB, converted to MiB; gets rid of the "improperly aligned" warning.
    rootEndMiB=$(( ( $(blockdev --getsize64 "${device}") - ${swapSize} * 1024 * 1024 * 1024 ) / 1024 / 1024 ))
    parted -s -a optimal "${device}" -- mkpart root ext4 513MiB "''${rootEndMiB}MiB"
    parted -s -a optimal "${device}" -- mkpart swap linux-swap "''${rootEndMiB}MiB" 100%

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

    disks-create = pkgs.symlinkJoin {
      name = "disks-create";
      paths = [
        (pkgs.writeShellScriptBin "disks-create" partitionsCreateScript)
        pkgs.parted
        pkgs.util-linux
      ];
    };

    disks-format = pkgs.symlinkJoin {
      name = "disks-format";
      paths = [
        (pkgs.writeShellScriptBin "disks-format" partitionsFormatScript)
        pkgs.dosfstools
        pkgs.e2fsprogs
        pkgs.util-linux
      ];
    };

    disks-mount = pkgs.symlinkJoin {
      name = "disks-mount";
      paths = [
        (pkgs.writeShellScriptBin "disks-mount" partitionsMountScript)
        pkgs.util-linux
      ];
    };
  };
}
