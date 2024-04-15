{
  config,
  lib,
  pkgs,
  ...
}: {
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    wlr.enable = true;
    extraPortals = with pkgs; [xdg-desktop-portal-gtk];
  };
}
