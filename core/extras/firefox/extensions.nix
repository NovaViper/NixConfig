{
  config,
  lib,
  pkgs,
  ...
}: let
  extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    ublock-origin
    sponsorblock
    return-youtube-dislikes
    darkreader
    #bypass-paywalls-clean
    plasma-integration
    enhancer-for-youtube
    indie-wiki-buddy
    stylus
    canvasblocker
  ];
in {
  hmUser = lib.singleton (hm: let
    hm-config = hm.config;
  in {
    programs.floorp.profiles."${hm-config.home.username}".extensions.packages = extensions;
    programs.firefox.profiles."${hm-config.home.username}".extensions.packages = extensions;
  });
}
