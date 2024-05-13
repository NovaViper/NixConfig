{
  config,
  lib,
  pkgs,
  ...
}: {
  # Hint electron apps to use wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    xwaylandvideobridge
    libsForQt5.qt5.qtwayland
    qt6.qtwayland
  ];
}
