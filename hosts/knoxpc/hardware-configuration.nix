{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "mpt3sas"
    "nvme"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  zramSwap.enable = true;

  # ZFS
  networking.hostId = lib.substring 0 8 (builtins.hashString "sha256" config.networking.hostName);
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "pool0" ];
  boot.kernelParams = [
    "zfs.zfs_arc_max=0" # Use ZFS's default dynamic cache allocation
    "zfs.zfs_txg_timeout=5" # Transaction latency optimization
  ];
  services.zfs.autoScrub.enable = true; # Periodic data integrity checks
  services.zfs.autoScrub.pools = [ "pool0" ];
  environment.systemPackages = with pkgs; [ zfs ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
