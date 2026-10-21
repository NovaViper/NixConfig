{ pkgs, myLib, ... }:
let
  device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_1000GB_251637800361";
  swapSize = "32"; # GiB
  cryptOpts = [
    "tpm2-device=auto"
    "fido2-device=auto"
    "token-timeout=10"
  ];

  partitionsCreateScript = ''
    parted -s "${device}" mklabel gpt
    parted -s "${device}" mkpart ESP fat32 1MiB 513MiB
    parted -s "${device}" set 1 esp on

    swapStartMiB=${myLib.utils.swapStartMiB device swapSize}
    parted -s -a optimal "${device}" -- mkpart luksRoot 513MiB "''${swapStartMiB}MiB"
    parted -s -a optimal "${device}" -- mkpart luksSwap "''${swapStartMiB}MiB" 100%

    udevadm trigger --subsystem-match=block
    udevadm settle
  '';
  partitionsFormatScript = ''
    mkfs.vfat -n ESP "${device}-part1"

    cryptsetup -q luksFormat --type luks2 "${device}-part2"
    cryptsetup open "${device}-part2" cryptroot
    mkfs.btrfs -f /dev/mapper/cryptroot
    mount /dev/mapper/cryptroot /mnt
    btrfs subvolume create /mnt/@root
    btrfs subvolume create /mnt/@home
    umount /mnt
    systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 "${device}-part2"
    systemd-cryptenroll --fido2-device=auto "${device}-part2"
    cryptsetup close cryptroot

    cryptsetup -q luksFormat --type luks2 "${device}-part3"
    cryptsetup open "${device}-part3" cryptswap
    mkswap /dev/mapper/cryptswap
    systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 "${device}-part3"
    systemd-cryptenroll --fido2-device=auto "${device}-part3"
    cryptsetup close cryptswap
  '';
  partitionsMountScript = ''
    systemd-cryptenroll attach cryptroot /dev/disk/by-partlabel/luksRoot -- tpm2-device=auto,fido2-device=auto
    mount -o subvol=@root,compress=zstd,noatime /dev/mapper/cryptroot /mnt
    mkdir -p /mnt/{boot,home}
    mount -o subvol=@home,compress=zstd,noatime /dev/mapper/cryptroot /mnt/home
    mount /dev/disk/by-partlabel/ESP /mnt/boot

    systemd-cryptenroll attach cryptswap /dev/disk/by-partlabel/luksSwap -- tpm2-device=auto,fido2-device=auto
    swapon /dev/mapper/cryptswap
  '';
in
{
  config = {
    # Enable systemd in initrd to support TPM2 and FIDO2 for unlocking LUKS volumes
    boot.initrd.systemd.enable = true;
    # Enable TPM2 support in initrd for unlocking LUKS volumes
    security.tpm2.enable = true;
    security.tpm2.pkcs11.enable = true;
    security.tpm2.tctiEnvironment.enable = true;

    fileSystems."/boot" = {
      device = "/dev/disk/by-partlabel/ESP";
      fsType = "vfat";
      options = [
        "defaults"
        "relatime"
        "umask=0077"
      ];
    };

    boot.initrd.luks.devices = {
      cryptroot = {
        device = "/dev/disk/by-partlabel/luksRoot";
        allowDiscards = true;
        crypttabExtraOpts = cryptOpts;
      };
      cryptswap = {
        device = "/dev/disk/by-partlabel/luksSwap";
        allowDiscards = true;
        crypttabExtraOpts = cryptOpts;
      };
    };

    fileSystems."/" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [
        "subvol=@root"
        "compress=zstd"
        "noatime"
      ];
    };

    fileSystems."/home" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [
        "subvol=@home"
        "compress=zstd"
        "noatime"
      ];
    };

    swapDevices = [
      {
        device = "/dev/mapper/cryptswap";
        randomEncryption = false;
      }
    ];

    boot.resumeDevice = "/dev/mapper/cryptswap";

    disks-create = myLib.utils.mkDiskScript pkgs "disks-create" partitionsCreateScript [
      pkgs.parted
      pkgs.util-linux
    ];

    disks-format = myLib.utils.mkDiskScript pkgs "disks-format" partitionsFormatScript [
      pkgs.dosfstools
      pkgs.cryptsetup
      pkgs.btrfs-progs
      pkgs.systemd
    ];

    disks-mount = myLib.utils.mkDiskScript pkgs "disks-mount" partitionsMountScript [
      pkgs.cryptsetup
      pkgs.util-linux
    ];
  };
}
