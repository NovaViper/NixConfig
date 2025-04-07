{
  config,
  lib,
  myLib,
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
  hmShared = lib.singleton (hm: let
    username = hm.config.home.username;
  in {
    programs.floorp.profiles."${username}".extensions.packages = extensions;
    programs.firefox.profiles."${username}".extensions.packages = extensions;
  });
}
