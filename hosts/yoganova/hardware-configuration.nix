{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  MAIN_PART = "/dev/disk/by-uuid/4396870a-b30b-4ead-af0c-09436cbe176a";
  BOOT_PART = "/dev/disk/by-uuid/7CF1-022D";
  SWAP_PATH = "/swapfile";
  SWAP_SIZE = 16;
  RESUME_OFFSET = "111116288";
in {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot = {
    # Bootloader
    loader = {
      systemd-boot = {
        enable = true;
        memtest86.enable = true;
        # Limit the number of generations to keep
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "sdhci_pci"];
      kernelModules = ["ideapad_laptop"];
    };
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];

    # Swapfile hibernate
    resumeDevice = "${MAIN_PART}";
    kernelParams = ["resume_offset=${RESUME_OFFSET}"];
  };

  fileSystems = {
    "/" = {
      device = "${MAIN_PART}";
      fsType = "ext4";
      options = ["noatime" "defaults"];
    };

    "/boot" = {
      device = "${BOOT_PART}";
      fsType = "vfat";
      options = ["relatime" "umask=0077" "defaults"];
    };
  };

  swapDevices = [
    {
      device = "${SWAP_PATH}";
      size = SWAP_SIZE * 1024;
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
