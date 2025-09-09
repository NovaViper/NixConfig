{
  config,
  lib,
  pkgs,
  ...
}:
let
  hm-config = config.hm;
  extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    ublock-origin
    sponsorblock
    return-youtube-dislikes
    darkreader
    #bypass-paywalls-clean
    plasma-integration
    indie-wiki-buddy
    stylus
    canvasblocker
  ];
in
{
  hm.programs.floorp.profiles."${hm-config.home.username}".extensions = {
    packages = extensions;
    force = true;
  };

  hm.programs.firefox.profiles."${hm-config.home.username}".extensions = {
    packages = extensions;
    force = true;
  };
}
