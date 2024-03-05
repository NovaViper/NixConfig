{ config, lib, pkgs, ... }:
with lib;

{
  imports = [ ../common.nix ];

  xdg = {
    portal = {
      extraPortals = with pkgs; [ libsForQt5.xdg-desktop-portal-kde ];
      configPackages = with pkgs;
        mkDefault [ libsForQt5.xdg-desktop-portal-kde ];
    };
    # Dolphin settings
    dataFile."kxmlgui5/dolphin/dolphinui.rc".source =
      config.lib.file.mkOutOfStoreSymlink
      "${config.home.sessionVariables.FLAKE}/home/novaviper/dots/dolphin/dolphinui.rc";
  };

  programs.plasma.workspace.clickItemTo = "select";
}
