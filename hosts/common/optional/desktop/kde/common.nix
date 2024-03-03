{ config, lib, pkgs, ... }:
with lib;
let desktopEnv = config.services.xserver.desktopManager;
in {
  imports = [ ../global.nix ../wayland.nix ../x11.nix ];

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
        plasma-hud
        kdiskmark

        # Libraries/Utilities
        clinfo # for kinfocenter for OpenCL page
        glxinfo # for kinfocenter for OpenGL EGL and GLX page
        vulkan-tools # for kinfocenter for Vulkan page
        linuxquota # for plasma-disks
        ffmpegthumbnailer
        wayland-utils
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
      ExecStart = (if (desktopEnv.plasma6.enable) then
        "${pkgs.kdePackages.kdeconnect-kde}/libexec/kdeconnectd"
      else
        "${pkgs.plasma5Packages.kdeconnect-kde}/libexec/kdeconnectd");
      Restart = "on-abort";
    };
  };
}
