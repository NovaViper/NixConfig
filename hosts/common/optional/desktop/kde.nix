{ config, lib, pkgs, ... }:

{
  imports = [ ./global.nix ./x11.nix ./wayland.nix ];

  # Special Variables
  variables.desktop.environment = "kde";

  # Enable the KDE Plasma Desktop Environment.
  services.xserver = {
    displayManager.sddm = {
      enable = true;
      autoNumlock = true;
    };
    desktopManager.plasma5.enable = true;
  };

  # Enable KDE partition manager
  programs = {
    partition-manager.enable = true;
    kdeconnect.enable = true;
  };

  environment = {
    plasma5.excludePackages = with pkgs.libsForQt5; [ elisa ];
    systemPackages = with pkgs; [
      # Apps
      #kate
      ktorrent
      krename
      kfind
      qalculate-qt
      plasma-hud
      libsForQt5.filelight
      libsForQt5.skanpage # Scanner
      libsForQt5.plasma-welcome # Welcome screen
      libsForQt5.plasma-vault
      libsForQt5.plasma-disks
      kdiskmark

      # Libraries/Utilities
      clinfo # for kinfocenter for OpenCL page
      glxinfo # for kinfocenter for OpenGL EGL and GLX page
      vulkan-tools # for kinfocenter for Vulkan page
      linuxquota # for plasma-disks
      libsForQt5.kdegraphics-thumbnailers
      libsForQt5.ffmpegthumbs
      ffmpegthumbnailer
      wayland-utils
      libsForQt5.qt5.qtimageformats
      libsForQt5.packagekit-qt
    ];
  };

  # Create system services for KDE connect
  systemd.user.services.kdeconnect = {
    description = "Adds communication between your desktop and your smartphone";
    after = [ "graphical-session-pre.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      #Environment = "PATH=${config.home.profileDirectory}/bin";
      ExecStart = "${pkgs.plasma5Packages.kdeconnect-kde}/libexec/kdeconnectd";
      Restart = "on-abort";
    };
  };
}
