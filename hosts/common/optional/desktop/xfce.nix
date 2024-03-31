{ config, lib, pkgs, ... }:

{
  imports = [ ./common ./displayManager/x11.nix ];

  # Special Variables
  variables.desktop.environment = "xfce";

  services = {
    # Enable blueman if bluetooth is enabled
    blueman.enable = lib.mkDefault config.hardware.bluetooth.enable;
    # Enable the XFCE Desktop Environment.
    xserver = {
      displayManager.lightdm.enable = true;
      desktopManager.xfce.enable = true;
    };
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-media-tags-plugin
      thunar-volman
      thunar-archive-plugin
    ];
  };

  environment.systemPackages = with pkgs; [
    # General
    gnome.simple-scan

    # XFCE General
    gparted
    dockbarx
    font-manager
    libqalculate
    qalculate-gtk
    cinnamon.xreader
    xfce.catfish
    xfce.xfdashboard
    xfce.xfce4-dict
    xfce.xfburn
    xfce.gigolo
    xfce.orage
    baobab
    gnome.file-roller
    qalculate-gtk

    # XFCE Panel plugins
    xfce.xfce4-windowck-plugin
    xfce.xfce4-pulseaudio-plugin
    xfce.xfce4-dockbarx-plugin
    xfce.xfce4-whiskermenu-plugin
    xfce.xfce4-weather-plugin
    xfce.xfce4-clipman-plugin
    xfce.xfce4-xkb-plugin
    xfce.xfce4-netload-plugin
    xfce.xfce4-genmon-plugin
    xfce.xfce4-fsguard-plugin
  ];
}
