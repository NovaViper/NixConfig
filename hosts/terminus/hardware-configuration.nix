# Based on nixos-generate-config output from the live OCI installer,
# with the host's serial console and zram settings maintained here.
{
  lib,
  modulesPath,
  ...
}:
{
  # Hardware detected by nixos-generate-config in the live OCI installer.
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "virtio_pci"
    "virtio_scsi"
    "usbhid"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Send Linux console output to Oracle's ARM serial console.
  boot.kernelParams = [ "console=ttyAMA0,115200" ];

  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };
}
