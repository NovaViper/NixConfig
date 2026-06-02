{
  config,
  lib,
  pkgs,
  ...
}:
let
  hm-config = config.hm;

  extensions = with pkgs.inputs.firefox-addons; [
    ublock-origin
    sponsorblock
    dearrow
    return-youtube-dislikes
    darkreader
    #bypass-paywalls-clean
    plasma-integration
    indie-wiki-buddy
    stylus
    canvasblocker
    steam-database
  ];
  extensionSettings = {
    "keepassxc-browser@keepassxc.org".settings."settings" = {
      "colorTheme" = "system";
      defaultPasswordManager = true;
      autoReconnect = true;
      passkeys = true;
      passkeysFallback = true;
      usePasswordGeneratorIcons = true;
      saveDomainOnly = true;
      downloadFaviconAfterSave = true;
    };
  };
in
{
  hm.programs.floorp.profiles."${hm-config.home.username}".extensions = {
    packages = extensions;
    settings = extensionSettings;
    force = true;
  };

  hm.programs.firefox.profiles."${hm-config.home.username}".extensions = {
    packages = extensions;
    settings = extensionSettings;
    force = true;
  };
}
