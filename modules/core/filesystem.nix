{pkgs, ...}: {
  services.usbmuxd.enable = true;

  environment.systemPackages = with pkgs; [
    libimobiledevice
    ifuse # optional, to mount using 'ifuse'
    gvfs
    usbmuxd
  ];

  boot.supportedFilesystems = [
    "btrfs"
    "ext2"
    "ext3"
    "ext4"
    "exfat"
    "f2fs"
    "fat8"
    "fat16"
    "fat32"
    "ntfs"
    "xfs"
  ];
}
