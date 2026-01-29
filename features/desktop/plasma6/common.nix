{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
{
  features.desktop = "kde";
  features.useWayland = true;

  # Enable the KDE's SDDM.
  services.displayManager.sddm = {
    enable = true;
    autoNumlock = true;
    enableHidpi = true;
    wayland.enable = true;
  };

  # Enable Desktop Environment
  services.desktopManager.plasma6 = {
    enable = true;
    enableQt5Integration = true;
  };
  # Enable KDE partition manager configs
  programs.partition-manager.enable = true;

  # Add kdeconnect ports
  networking.firewall = rec {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };

  environment.plasma6.excludePackages = with pkgs.kdePackages; [ elisa ];

  environment.systemPackages =
    with pkgs;
    [
      # Apps
      kdePackages.ktorrent
      kdePackages.kfind
      kdePackages.filelight
      klassy

      # Libraries/Utilities
      clinfo # for kinfocenter for OpenCL page
      mesa-demos # for kinfocenter for OpenGL EGL and GLX page
      vulkan-tools # for kinfocenter for Vulkan page
      wayland-utils # for kinfocenter for Wayland page
      ffmpegthumbnailer # for video thumbnails
      gnuplot # for krunner to display graphs
      kdePackages.kdegraphics-thumbnailers
    ]
    ++ lib.optionals (config.networking.hostName != "installer") [
      # Apps
      qalculate-qt
      kdiskmark
      kdePackages.skanpage # Scanner
      kdePackages.print-manager
      kdePackages.plasma-welcome # Welcome screen
      kdePackages.plasma-vault

      # Libraries/Utilities
      kdePackages.plasma-disks
      linuxquota # for plasma-disks
      libdbusmenu # For global menu support with electron apps
      kdePackages.sddm-kcm # Add KCM for sddm
      kdePackages.ffmpegthumbs
      kdePackages.qtimageformats
      kdePackages.packagekit-qt
    ];

  hm.programs.plasma.configFile."kwinrc"."Xwayland"."Scale" = config.hostVars.scalingFactor;

  # Enable kdeconnect service
  hm.services.kdeconnect.enable = true;

  hm.xdg.mimeApps = {
    defaultApplications."x-scheme-handler/tel" = [ "org.kde.kdeconnect.handler.desktop" ];
    associations.added."x-scheme-handler/tel" = [ "org.kde.kdeconnect.handler.desktop" ];
  };
}
