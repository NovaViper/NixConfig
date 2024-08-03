{
  config,
  lib,
  pkgs,
  ...
}: {
  environment.sessionVariables = {
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
    # Make Gnome use Wayland
    GDK_BACKEND = "wayland,x11";
    XDG_SESSION_TYPE = "wayland";
    # Make Steam not crash under wayland
    SDL_VIDEODRIVER = "x11";
    CLUTTER_BACKEND = "wayland";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  environment.systemPackages = with pkgs; [
    xwaylandvideobridge
    libsForQt5.qt5.qtwayland
    qt6.qtwayland
  ];
}
