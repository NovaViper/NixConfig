{ config, lib, pkgs, ... }:

{
  dconf.settings = {
    "org/virt-manager/virt-manager" = {
      system-tray = true;
      xmleditor-enabled = true;
    };

    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };

    "org/virt-manager/virt-manager/stats" = {
      enable-disk-poll = true;
      enable-memory-poll = true;
      enable-net-poll = true;
    };

    "org/virt-manager/virt-manager/console" = {
      resize-guest = 1;
      scaling = 2;
    };

    "org/virt-manager/virt-manager/new-vm" = {
      cpu-default = "host-passthrough";
    };
  };
}
