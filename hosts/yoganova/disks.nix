{ config, lib, inputs, pkgs, ... }:
let
  DISK = "/dev/disk/by-id/nvme-WD_PC_SN740_SDDPMQD-512G-1101_22452M447518";
  MEMORY = "8G";

  partitionsCreateScript = ''
    sudo sgdisk -Z -a 2048 -o ${DISK}
    sudo sgdisk -n 1::+512M -t 1:ef00 -c 1:BOOT ${DISK}
    sudo sgdisk -n 2::-${MEMORY} -t 2:8300 -c 2:nixos ${DISK}
    sudo sgdisk -n 3::0 -t 3:8200 -c 3:swap ${DISK}
    sudo udevadm trigger --subsystem-match=block; udevadm settle
  '';
  partitionsFormatScript = ''
    sudo mkfs.vfat "${DISK}"-part1
    sudo mkfs.ext4 "${DISK}"-part2
    sudo mkswap "${DISK}"-part3
  '';
  partitionsMountScript = ''
    sudo mount /dev/disk/by-partlabel/nixos /mnt
    sudo mkdir -p /mnt/{boot,nix}

    sudo mount /dev/disk/by-partlabel/BOOT /mnt/boot
    sudo swapon /dev/disk/by-partlabel/swap
  '';
in {

  config.environment.systemPackages =
    [ config.disks-create config.disks-format config.disks-mount ];

  options.disks-create = with lib;
    mkOption rec {
      type = types.package;
      default = with pkgs;
        symlinkJoin {
          name = "disks-create";
          paths =
            [ (writeScriptBin default.name partitionsCreateScript) gptfdisk ];
        };
    };

  options.disks-format = with lib;
    mkOption rec {
      type = types.package;
      default = with pkgs;
        symlinkJoin {
          name = "disks-format";
          paths = [
            (writeScriptBin default.name partitionsFormatScript)
            cryptsetup
            lvm2
            dosfstools
            e2fsprogs
            btrfs-progs
          ];
        };
    };

  options.disks-mount = with lib;
    mkOption rec {
      type = types.package;
      default = with pkgs;
        symlinkJoin {
          name = "disks-mount";
          paths = [
            (writeScriptBin default.name partitionsMountScript)
            cryptsetup
            lvm2
          ];
        };
    };
}
