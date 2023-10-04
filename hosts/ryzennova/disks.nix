{ config, lib, inputs, pkgs, ... }:
let
  DISK = "/dev/disk/by-id/nvme-Sabrent_Rocket_Q_BE72071303B600060935";
  SWAP = "/swapfile";

  partitionsCreateScript = ''
    sudo sgdisk -Z -a 2048 -o ${DISK}
    sudo sgdisk -n 1::+512M -t 1:ef00 -c 1:BOOT ${DISK}
    sudo sgdisk -n 2::0 -t 2:8300 -c 2:nixos ${DISK}
    sudo udevadm trigger --subsystem-match=block; udevadm settle
  '';
  partitionsFormatScript = ''
    sudo mkfs.vfat "${DISK}"-part1
    sudo mkfs.ext4 "${DISK}"-part2
  '';
  partitionsMountScript = ''
    sudo mount /dev/disk/by-partlabel/nixos /mnt
    sudo mkdir -p /mnt/{boot,nix}

    sudo mount /dev/disk/by-partlabel/BOOT /mnt/boot
  '';
  resumeOffsetScript = ''
    sudo filefrag -v ${SWAP} | awk '$1=="0:" {print substr($4, 1, length($4)-2)}'
  '';
in {

  config.environment.systemPackages = [
    config.disks-create
    config.disks-format
    config.disks-mount
    config.get-resume-offset
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

  options.get-resume-offset = with lib;
    mkOption rec {
      type = types.package;
      default = with pkgs;
        symlinkJoin {
          name = "get-resume-offset";
          paths =
            [ (writeScriptBin default.name resumeOffsetScript) e2fsprogs ];
        };
    };
}
