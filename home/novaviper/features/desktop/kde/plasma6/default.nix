{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault;
in {
  imports = [../common.nix];

  xdg.portal = {
    extraPortals = with pkgs.kdePackages; [xdg-desktop-portal-kde];
    configPackages = with pkgs.kdePackages;
      mkDefault [xdg-desktop-portal-kde];

    # Dolphin settings
    #dataFile."kxmlgui5/dolphin/dolphinui.rc".source = utils.linkDots "dolphin/dolphinui.rc";
  };

  services.kdeconnect.package = pkgs.kdePackages.kdeconnect-kde;

  # Add Firefox native messaging host support for Plasma Integration
  programs.firefox.nativeMessagingHosts = with pkgs; [kdePackages.plasma-browser-integration];
}
