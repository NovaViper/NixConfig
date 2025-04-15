{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: {
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

  programs.partition-manager.enable = true;
  programs.kdeconnect.enable = true;

  home-manager.sharedModules = lib.singleton {
    services.kdeconnect = {
      enable = true;
      package = pkgs.kdePackages.kdeconnect-kde;
    };

    xdg.mimeApps = {
      defaultApplications."x-scheme-handler/tel" = ["org.kde.kdeconnect.handler.desktop"];
      associations.added."x-scheme-handler/tel" = ["org.kde.kdeconnect.handler.desktop"];
    };
  };

  environment.plasma6.excludePackages = with pkgs.kdePackages; [elisa];

  environment.systemPackages = with pkgs;
    [
      # Apps
      krename
      kdePackages.ktorrent
      kdePackages.kfind
      kdePackages.filelight

      # Libraries/Utilities
      clinfo # for kinfocenter for OpenCL page
      glxinfo # for kinfocenter for OpenGL EGL and GLX page
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
}
