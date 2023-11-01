{ config, lib, pkgs, ... }:

{

  imports = [ ../pipewire.nix ../printing.nix ../xdg.nix ];

  services = {
    # Enable the X11 windowing system.
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

    # Replace power-profile-daemon with tlp since it's no longer maintained
    #power-profiles-daemon.enable = lib.mkForce false;
    #tlp.enable = lib.mkForce true;
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable for GTK
  programs.dconf.enable = true;

  #environment.persistence = { "/persist".directories = [ "/etc/NetworkManager" ]; };

  # Install installation
  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    systemPackages = with pkgs; [
      # X11
      libnotify
      xorg.xkbutils
      xorg.xkill

      #PDF
      poppler

      # Enable guestures for touchpad
      libinput-gestures
    ];
  };
}
