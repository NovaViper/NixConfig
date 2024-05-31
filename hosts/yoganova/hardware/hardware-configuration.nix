{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  MAIN_PART = "/dev/disk/by-uuid/b2248de3-d040-40eb-981d-06d9c9f11510";
  BOOT_PART = "/dev/disk/by-uuid/B298-585F";
  SWAP_PATH = "/swapfile";
  SWAP_SIZE = 16;
  RESUME_OFFSET = "89620480";
in {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot = {
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
