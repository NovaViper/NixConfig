{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: let
  hm-config = config.hm;
in
  myLib.utilMods.mkModule config "plasma6" {
    modules.desktop.enable = true;
    modules.desktop.x11.enable = lib.mkForce true;
    modules.desktop.wayland.enable = lib.mkForce true;

    # Enable the KDE's SDDM.
    services.displayManager.sddm = {
      enable = true;
      autoNumlock = true;
      enableHidpi = true;
      wayland.enable = true;
      extraPackages = with pkgs; [
        kdePackages.qtsvg
        kdePackages.qtmultimedia
        kdePackages.qtvirtualkeyboard
      ];
    };

    # Enable Desktop Environment
    services.desktopManager.plasma6 = {
      enable = true;
      enableQt5Integration = true;
    };

    environment.plasma6.excludePackages = with pkgs.kdePackages; [elisa];

    # Enable KDE partition manager
    programs.partition-manager.enable = true;
    # Enable KDEConnect
    programs.kdeconnect.enable = true;

    environment.systemPackages = with pkgs;
      [
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
        gnuplot # for krunner to display graphs
        libdbusmenu # For global menu support with electron apps
      ]
      ++ (with kdePackages; [
        # Apps
        ktorrent
        kfind
        filelight
        skanpage # Scanner
        print-manager
        plasma-welcome # Welcome screen
        plasma-vault
        plasma-disks

        # Libraries/Utilities
        kdegraphics-thumbnailers
        ffmpegthumbs
        qtimageformats
        packagekit-qt
        sddm-kcm # Add KCM for sddm
      ]);

    hm.xdg.portal = {
      enable = true;
      configPackages = with pkgs; lib.mkDefault [kdePackages.xdg-desktop-portal-kde];
      extraPortals = with pkgs; [xdg-desktop-portal-gtk];
    };

    # Enable native messaging host for Firefox/Firefox forks
    hm.programs.firefox.nativeMessagingHosts = with pkgs; [kdePackages.plasma-browser-integration];

    hm.services.kdeconnect = {
      enable = true;
      package = pkgs.kdePackages.kdeconnect-kde;
    };

    hm.xdg.mimeApps = {
      defaultApplications."x-scheme-handler/tel" = ["org.kde.kdeconnect.handler.desktop"];
      associations.added."x-scheme-handler/tel" = ["org.kde.kdeconnect.handler.desktop"];
    };

    # Makes Plasma Browser Integration work properly for Vivaldi
    create.configFile."vivaldi/NativeMessagingHosts/org.kde.plasma.browser_integration.json" = lib.mkIf hm-config.programs.vivaldi.enable {source = "${pkgs.kdePackages.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";};
  }
