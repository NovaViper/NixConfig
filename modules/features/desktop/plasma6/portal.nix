{
  lib,
  pkgs,
  ...
}: {
  hm.xdg.portal = {
    enable = true;
    configPackages = with pkgs; lib.mkDefault [kdePackages.xdg-desktop-portal-kde];
    extraPortals = with pkgs; [xdg-desktop-portal-gtk];
  };
}
