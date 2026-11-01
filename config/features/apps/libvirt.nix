{
  config,
  pkgs,
  username,
  ...
}:
{
  users.users.${username}.extraGroups = [ "libvirtd" ];

  # Install necessary packages
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    #spice
    #spice-gtk
    #spice-protocol
    virtio-win
    win-spice
    # TODO: Broken currently, waiting until https://github.com/NixOS/nixpkgs/pull/581034
    # guestfs-tools
    # libguestfs
  ];

  # Manage the virutalisation services
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };

  services.spice-vdagentd.enable = true;
}
