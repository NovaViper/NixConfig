{ config, lib, pkgs, ... }:
with lib;
let
  desktopEnv = config.services.xserver.desktopManager;
  kdeconnect-pkg = if (desktopEnv.plasma5.enable) then
    pkgs.plasma5Packages.kdeconnect-kde
  else
    pkgs.kdePackages.kdeconnect-kde;
in {
  imports =
    [ ../common ../displayManager/wayland.nix ../displayManager/x11.nix ];

  # Special Variables
  variables.desktop.environment = "kde";

  # Enable the KDE's SDDM.
  services.xserver = {
    displayManager.sddm = {
      enable = true;
      autoNumlock = true;
    };
  };

  # Enable KDE partition manager
  programs = {
    partition-manager.enable = true;
    kdeconnect.enable = true;
  };

  environment.systemPackages = with pkgs;
    (mkMerge [
      ([
        # Apps
        krename
        qalculate-qt
        kdiskmark

        # Libraries/Utilities
        clinfo # for kinfocenter for OpenCL page
        glxinfo # for kinfocenter for OpenGL EGL and GLX page
        vulkan-tools # for kinfocenter for Vulkan page
        wayland-utils # for kinfocenter for Wayland page
        ffmpegthumbnailer # for video thumbnails
        linuxquota # for plasma-disks
      ])

      (with libsForQt5;
        mkIf (desktopEnv.plasma5.enable) [
          # Apps
          ktorrent
          kfind
          filelight
          skanpage # Scanner
          plasma-welcome # Welcome screen
          plasma-vault
          plasma-disks

          # Libraries/Utilities
          kdegraphics-thumbnailers
          ffmpegthumbs
          qt5.qtimageformats
          packagekit-qt
        ])
      (with kdePackages;
        mkIf (desktopEnv.plasma6.enable) [
          # Apps
          ktorrent
          kfind
          filelight
          skanpage # Scanner
          plasma-welcome # Welcome screen
          plasma-vault
          plasma-disks

          # Libraries/Utilities
          kdegraphics-thumbnailers
          ffmpegthumbs
          qtimageformats
          packagekit-qt
        ])
    ]);

  # Create system services for KDE connect
  systemd.user.services.kdeconnect = {
    description = "Adds communication between your desktop and your smartphone";
    after = [ "graphical-session-pre.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      #Environment = "PATH=${config.home.profileDirectory}/bin";
      ExecStart = "${kdeconnect-pkg}/libexec/kdeconnectd";
      Restart = "on-abort";
    };
  };
}
