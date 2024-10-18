{
  outputs,
  config,
  pkgs,
  ...
}:
{imports = [./displayManager/x11.nix ./displayManager/wayland.nix];}
// outputs.lib.mkDesktopModule config "plasma6" {
  modules.wayland.enable = true;
  modules.x11.enable = true;

  xdg.portal = {
    enable = true;
    configPackages = with pkgs; outputs.lib.mkDefault [kdePackages.xdg-desktop-portal-kde];
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # Enable native messaging host for Firefox/Firefox forks
  programs.firefox.nativeMessagingHosts = with pkgs; [kdePackages.plasma-browser-integration];

  # Makes Plasma Browser Integration work properly for Vivaldi
  xdg.configFile."vivaldi/NativeMessagingHosts/org.kde.plasma.browser_integration.json" = outputs.lib.mkIf config.programs.vivaldi.enable {source = "${pkgs.kdePackages.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";};

  services.kdeconnect = {
    enable = true;
    package = pkgs.kdePackages.kdeconnect-kde;
  };

  xdg = {
    mimeApps = {
      associations = {
        added = {
          "x-scheme-handler/tel" = ["org.kde.kdeconnect.handler.desktop"];
        };
      };
      defaultApplications = {
        "x-scheme-handler/tel" = ["org.kde.kdeconnect.handler.desktop"];
      };
    };
  };

  nixos = {
    services = {
      # Enable the KDE's SDDM.
      displayManager.sddm = {
        enable = true;
        autoNumlock = true;
        enableHidpi = true;
        wayland.enable = true;
      };
      # Enable Desktop Environment
      desktopManager.plasma6 = {
        enable = true;
        enableQt5Integration = true;
      };
    };

    environment.plasma6.excludePackages = with pkgs.kdePackages; [elisa];

    # Enable KDE partition manager
    programs = {
      partition-manager.enable = true;
      kdeconnect.enable = true;
    };

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
  };
}
