{ config, lib, inputs, pkgs, ... }:
let
  DISK = "/dev/disk/by-id/nvme-WD_PC_SN740_SDDPMQD-512G-1101_22452M447518";
  SWAP_PATH = "/swapfile";
  SWAP_SIZE = "16";

  partitionsCreateScript = ''
    sudo sgdisk -Z -a 2048 -o ${DISK}
    sudo sgdisk -n 1::+512M -t 1:ef00 -c 1:BOOT ${DISK}
    sudo sgdisk -n 2::0 -t 2:8300 -c 2:nixos ${DISK}
    sudo udevadm trigger --subsystem-match=block; udevadm settle
    echo "Finished wiping disk and creating the partitions!"
  '';
  partitionsFormatScript = ''
    sudo mkfs.vfat "${DISK}"-part1
    sudo mkfs.ext4 "${DISK}"-part2
    echo "Finished formatting the partitions!"
  '';
  partitionsMountScript = ''
    sudo mount /dev/disk/by-partlabel/nixos /mnt
    sudo mkdir -p /mnt/{boot,nix}

    sudo mount /dev/disk/by-partlabel/BOOT /mnt/boot
    echo "The partitions are mounted at /mnt!"
  '';
  swapfileCreateScript = ''
    sudo dd if=/dev/zero of=/mnt${SWAP_PATH} bs=1M count=${SWAP_SIZE}k status=progress
    sudo chmod 600 /mnt${SWAP_PATH}
    sudo mkswap -U clear /mnt${SWAP_PATH}
    sudo swapon /mnt${SWAP_PATH}
    OFFSET=$(sudo filefrag -v /mnt${SWAP_PATH} | awk '$1=="0:" {print substr($4, 1, length($4)-2)}')
    echo "Finished creating the swapfile! The swap resume offset: "$OFFSET
  '';
  retrieveDiskID = ''
    DISKID=($(nixos-generate-config --show-hardware-config --root /mnt | grep -ho 'device.*' | sed 's/^.*= //'))
    echo MAIN_PART = ''${DISKID[0]}
    echo BOOT_PART = ''${DISKID[1]}
  '';
in {

  config.environment.systemPackages = [
    config.disks-create
    config.disks-format
    config.disks-mount
    config.disks-retrieve
    config.create-swapfile
  ];

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

  options.disks-retrieve = with lib;
    mkOption rec {
      type = types.package;
      default = with pkgs;
        symlinkJoin {
          name = "disks-retrieve";
          paths = [ (writeScriptBin default.name retrieveDiskID) ];
        };
    };

  options.create-swapfile = with lib;
    mkOption rec {
      type = types.package;
      default = with pkgs;
        symlinkJoin {
          name = "create-swapfile";
          paths =
            [ (writeScriptBin default.name swapfileCreateScript) e2fsprogs ];
        };
    };
}
