{
  outputs,
  config,
  pkgs,
  ...
}:
outputs.lib.mkModule config "x11" {
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

  nixos = {
    #xdg.portal.xdgOpenUsePortal = true;

    services = {
      # Enable the X11 windowing system.
      xserver = {
        enable = true;

        # Remove xterm terminal
        excludePackages = with pkgs; [xterm];
      };
    };

    # Install installation
    environment.systemPackages = with pkgs; [
      # X11
      xorg.xkbutils
      xorg.xkill
      xorg.libxcb
    ];
  };
}
