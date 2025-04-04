{
  config,
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
  hm.programs.floorp.profiles."${config.userVars.username}".extensions.packages = extensions;
  hm.programs.firefox.profiles."${config.userVars.username}".extensions.packages = extensions;
}
