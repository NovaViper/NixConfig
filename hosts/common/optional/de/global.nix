{ config, lib, pkgs, ... }:

{
  # Enable desktop integration
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  # Enable ALSA sound
  sound.enable = true;
  # Enable the RealtimeKit system service
  security.rtkit.enable = true;

  services = {
    # Enable Pipewire
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

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

  hardware = {
    # Disable PulseAudio
    pulseaudio.enable = false;
    # Scanner Setup
    sane = {
      enable = true;
      extraBackends = with pkgs; [ sane-airscan hplipWithPlugin ];
    };
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
      # Audio
      pavucontrol

      # X11
      libnotify
      xorg.xkbutils
      xorg.xkill

      #PDF
      poppler

      # Printers
      hplipWithPlugin
    ];
  };
}
