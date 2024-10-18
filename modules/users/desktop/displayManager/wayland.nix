{
  config,
  pkgs,
  outputs,
  ...
}: let
  waylandEnv = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    GDK_BACKEND = "wayland,x11";
    SDL_VIDEODRIVER = "x11";
    CLUTTER_BACKEND = "wayland";
    # QT_QPA_PLATFORM = "wayland";
    # LIBSEAT_BACKEND = "logind";
    XDG_SESSION_TYPE = "wayland";
    #WLR_NO_HARDWARE_CURSORS = "1";
    # _JAVA_AWT_WM_NONREPARENTING = "1";
    # GDK_SCALE = "2";
    # ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };
in
  outputs.lib.mkModule config "wayland" {
    home.sessionVariables = waylandEnv;
    # NOTE This will break stuff if there is a non-wayland user on the same machine,
    #  but application launchers need this.
    nixos.environment.sessionVariables = waylandEnv;

    nixos = {
      #xdg.portal.xdgOpenUsePortal = true;
      services.libinput.enable = true;
    };

    home.packages = with pkgs; [
      #xorg.xeyes
      kdePackages.xwaylandvideobridge
      libsForQt5.qt5.qtwayland
      qt6.qtwayland
    ];

    # https://discourse.nixos.org/t/home-manager-and-the-mimeapps-list-file-on-plasma-kde-desktops/37694/7
    xdg = {
      portal = {
        enable = true;
        xdgOpenUsePortal = true;
      };
      # Don't generate config at the usual place.
      # Allow desktop applications to write their file association
      # preferences to this file.
      configFile."mimeapps.list".enable = false;
      # Home-manager also writes xdg-mime-apps configuration to the
      # "deprecated" location. Desktop applications will look in this
      # list for associations, if no association was found in the
      # previous config file.
      dataFile."applications/mimeapps.list".force = true;
      mimeApps.enable = true;
    };
  }
