{ config, lib, pkgs, ... }:

{
  # Enable desktop integration
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  # Enable the X11 windowing system.
  services = {
    xserver = {
      enable = true;
      # Configure keymap in X11
      layout = "us";
      xkbVariant = "";

      # Enable touchpad support
      libinput.enable = true;

      # Remove xterm terminal
      excludePackages = with pkgs; [ xterm ];
    };

    # Printer Setup
    printing = {
      enable = true;
      drivers = with pkgs; [ hplipWithPlugin ];
    };
    avahi = {
      enable = true;
      nssmdns = true;
      # for a WiFi printer
      openFirewall = true;
    };
  };

  # Scanner Setup
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ sane-airscan hplipWithPlugin ];
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable for GTK
  programs.dconf.enable = true;

  # Install installation
  environment.systemPackages = with pkgs; [
    # X11
    libnotify
    xorg.xkbutils
    xorg.xkill
    xsane

    #PDF
    poppler

    # Printers
    hplipWithPlugin
  ];
}
