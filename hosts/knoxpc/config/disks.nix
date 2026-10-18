{ pkgs, lib, ... }:
# Based on https://github.com/Baitinq/nixos-config/blob/979313a290981f3c9f62fb5c6f180e87e331ac5f/hardware/pc/disks.nix
let
  bootDevice = "/dev/disk/by-id/nvme-WDC_PC_SN520_SDAPMUW-256G-1001_193463464112"; # 256 GB NVME drive
  swapSize = "32"; # GiB

  dataDisks = [
    "/dev/disk/by-id/wwn-0x500003955b98118a" # TOSHIBA_MG03ACA400 24E6K1EMF
    "/dev/disk/by-id/wwn-0x500003955bb01365" # TOSHIBA_MG03ACA400 24F9K0M1F
    "/dev/disk/by-id/wwn-0x5000c500797b5ed5" # ST4000NM0033_9ZM170 Z1Z5VJGJ
    "/dev/disk/by-id/wwn-0x500003955b802dd8" # TOSHIBA_MG03ACA400 24F3K2KFF
    "/dev/disk/by-id/wwn-0x500003955c080c2a" # TOSHIBA_MG03ACA400 24EKK07UF
    "/dev/disk/by-id/wwn-0x500003955b802dde" # TOSHIBA_MG03ACA400 24F3K2KLF
    "/dev/disk/by-id/wwn-0x500003955b980649" # TOSHIBA_MG03ACA400 2456K122F
    "/dev/disk/by-id/wwn-0x500003955bb815ae" # TOSHIBA_MG03ACA400 24FAK0U2F
  ];
  dataDiskParts = map (disk: "${disk}-part1") dataDisks;

  partitionsCreateScript = ''
    parted -s "${bootDevice}" mklabel gpt
    parted -s "${bootDevice}" mkpart ESP fat32 1MiB 513MiB
    parted -s "${bootDevice}" set 1 esp on

    # Compute an explicit end of the root partition in MiB, which is the total
    # size of the disk minus the swap size in GiB, converted to MiB; gets rid of the "improperly aligned" warning.
    rootEndMiB=$(( ( $(blockdev --getsize64 "${bootDevice}") - ${swapSize} * 1024 * 1024 * 1024 ) / 1024 / 1024 ))
    parted -s -a optimal "${bootDevice}" -- mkpart root ext4 513MiB "''${rootEndMiB}MiB"
    parted -s -a optimal "${bootDevice}" -- mkpart swap linux-swap "''${rootEndMiB}MiB" 100%

    ${lib.concatMapStringsSep "\n" (disk: ''
      wipefs -a "${disk}"
      parted -s "${disk}" mklabel gpt
      parted -s -a optimal "${disk}" -- mkpart zfs 1MiB 100%
    '') dataDisks}

    udevadm trigger --subsystem-match=block
    udevadm settle
  '';
  partitionsFormatScript = ''
    mkfs.vfat -n ESP "${bootDevice}-part1"
    mkfs.ext4 -L nixos "${bootDevice}-part2"
    mkswap -L swap "${bootDevice}-part3"

    # TODO: These came from disko.. unsure how much of this I actually need!
    zpool create \
      -f \
      -o ashift=12 \
      -O canmount=off \
      -O mountpoint=none \
      -O compression=zstd \
      -O atime=off \
      -O xattr=sa \
      -O acltype=posixacl \
      pool0 raidz2 ${lib.concatStringsSep " " dataDiskParts}
    zfs create -o mountpoint=/storage pool0/storage
    zfs create -o mountpoint=/storage/services pool0/services
    zfs create -o mountpoint=/storage/media pool0/media
    zfs create -o mountpoint=/storage/backups pool0/backups
    zpool export pool0
  '';
  partitionsMountScript = ''
    mount /dev/disk/by-partlabel/root /mnt
    mkdir -p /mnt/boot
    mount -o umask=0077 /dev/disk/by-partlabel/ESP /mnt/boot

    zpool import -d /dev/disk/by-id -R /mnt pool0
    zfs mount -a
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
        pkgs.zfs
      ];
    };

    disks-mount = pkgs.symlinkJoin {
      name = "disks-mount";
      paths = [
        (pkgs.writeShellScriptBin "disks-mount" partitionsMountScript)
        pkgs.util-linux
        pkgs.zfs
      ];
    };
  };
}
