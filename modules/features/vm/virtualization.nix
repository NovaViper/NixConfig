{
  config,
  lib,
  pkgs,
  ...
}:
lib.utilMods.mkDesktopModule config "virtualization" {
  # Enable dconf (System Management Tool)
  #programs.dconf.enable = true;

  # Install necessary packages
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    #spice
    #spice-gtk
    #spice-protocol
    win-virtio
    win-spice
    guestfs-tools
    libguestfs
  ];

  # Manage the virutalisation services
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
    qemu.ovmf = {
      enable = true;
      packages = with pkgs; [OVMFFull.fd];
    };
  };

  services.spice-vdagentd.enable = true;
}
