{ config, lib, pkgs, ... }:

{
  imports = [ ./pipewire.nix ./printing.nix ];

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable for GTK
  programs.dconf.enable = true;

  #environment.persistence = { "/persist".directories = [ "/etc/NetworkManager" ]; };

  # Install installation
  environment.systemPackages = with pkgs; [
    #Notifications
    libnotify

    #PDF
    poppler

    # Enable guestures for touchpad
    libinput-gestures
  ];
}
