{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  utils = import ../../../../../lib/utils.nix {inherit config pkgs;};
in {
  imports = [../common.nix];

  xdg = {
    portal = {
      extraPortals = with pkgs; [libsForQt5.xdg-desktop-portal-kde];
      configPackages = with pkgs;
        mkDefault [libsForQt5.xdg-desktop-portal-kde];
    };
    # Dolphin settings
    dataFile."kxmlgui5/dolphin/dolphinui.rc".source = utils.linkDots "dolphin/dolphinui.rc";
  };

  services.kdeconnect.package = pkgs.libsForQt5.kdeconnect-kde;

  programs.firefox.nativeMessagingHosts = with pkgs; [plasma5Packages.plasma-browser-integration];
}
