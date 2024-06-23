{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault;
  utils = import ../../../../../lib/utils.nix {inherit config pkgs;};
in {
  imports = [../common.nix];

  # Dolphin settings
  xdg.dataFile."kxmlgui5/dolphin/dolphinui.rc".source = utils.linkDots "dolphin/dolphinui.rc";

  services.kdeconnect.package = pkgs.libsForQt5.kdeconnect-kde;

  programs = {
    plasma.workspace.clickItemTo = mkDefault "select";
    firefox.nativeMessagingHosts = with pkgs; [plasma5Packages.plasma-browser-integration];
  };
}
