{
  config,
  lib,
  pkgs,
  ...
}: {
  home-manager.sharedModules = lib.singleton (hm: let
    hm-config = hm.config;
  in {
    # Enable native messaging host for Firefox/Firefox forks
    programs.firefox.nativeMessagingHosts = with pkgs; [kdePackages.plasma-browser-integration];

    # Makes Plasma Browser Integration work properly for Vivaldi
    xdg.configFile."vivaldi/NativeMessagingHosts/org.kde.plasma.browser_integration.json" = lib.mkIf hm-config.programs.vivaldi.enable {source = "${pkgs.kdePackages.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";};
  });
}
