{ config, lib, pkgs, ... }:

{
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
  ];

  # Manage the virutalisation services
  virtualisation = {
    spiceUSBRedirection.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = with pkgs; [ OVMFFull.fd ];
        };
      };
    };
  };

  services.spice-vdagentd.enable = true;
}
