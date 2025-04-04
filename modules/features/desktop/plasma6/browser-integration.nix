{
  config,
  lib,
  pkgs,
  ...
}: let
  hm-config = config.hm;
in {
  # Enable native messaging host for Firefox/Firefox forks
  hm.programs.firefox.nativeMessagingHosts = with pkgs; [kdePackages.plasma-browser-integration];

  # Makes Plasma Browser Integration work properly for Vivaldi
  hm.xdg.configFile."vivaldi/NativeMessagingHosts/org.kde.plasma.browser_integration.json" = lib.mkIf hm-config.programs.vivaldi.enable {source = "${pkgs.kdePackages.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";};
}
