{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./pipewire.nix ./printing.nix ./xdg.nix];

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable for GTK
  programs.dconf.enable = true;

  # Enable color management service
  services.colord.enable = true;

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
