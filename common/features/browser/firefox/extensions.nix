{pkgs, ...}:
with pkgs.nur.repos.rycee.firefox-addons; [
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
]
