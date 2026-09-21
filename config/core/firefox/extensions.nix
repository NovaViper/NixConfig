{
  config,
  lib,
  pkgs,
  ...
}:
let
  hm-config = config.hm;

  moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";

  # Extensions are obtained thanks to the guide here: https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265.
  # Check `about:support` for extension/add-on ID strings. Then find the
  # installation url by downloading the extension file (instead of installing it
  # directly). Always install the latest version of the extensions by using the
  # "latest" tag in the download url. Can also view the extensions source (Ctrl-U) and search for "guid"
  # (quotations included) to get the ID string

  # See also:
  # - https://github.com/mozilla/policy-templates/blob/master/linux/policies.json#L120
  # - https://mozilla.github.io/policy-templates/#extensionsettings
  extensions = {
    "uBlock0@raymondhill.net" = {
      install_url = moz "ublock-origin";
      installation_mode = "normal_installed";
      updates_disabled = true;
      private_browsing = true;
    };

    "sponsorBlocker@ajay.app" = {
      install_url = moz "sponsorblock";
      installation_mode = "normal_installed";
      updates_disabled = true;
    };

    "deArrow@ajay.app" = {
      install_url = moz "dearrow";
      installation_mode = "normal_installed";
      updates_disabled = true;
    };

    # ImprovedTube: https://github.com/code-charity/youtube
    "{3c6bf0cc-3ae2-42fb-9993-0d33104fdcaf}" = {
      install_url = moz "youtube-addon";
      installation_mode = "normal_installed";
      updates_disabled = true;
    };

    # # Return Youtube Dislikes
    # "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
    #   install_url = moz "return-youtube-dislikes";
    #   installation_mode = "normal_installed";
    #   updates_disabled = true;
    # };

    "addon@darkreader.org" = {
      install_url = moz "darkreader";
      installation_mode = "normal_installed";
      updates_disabled = true;
    };

    # "bypass-paywalls-clean@codeberg.org" = {
    #   install_url = moz "bypass-paywalls-clean";
    #   installation_mode = "normal_installed";
    # };

    "plasma-browser-integration@kde.org" = {
      install_url = moz "plasma-integration";
      installation_mode = "normal_installed";
      updates_disabled = true;
    };
    # Indie Wiki Buddy
    "{cb31ec5d-c49a-4e5a-b240-16c767444f62}" = {
      install_url = moz "indie-wiki-buddy";
      installation_mode = "normal_installed";
      updates_disabled = true;
    };

    # Stylus
    "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}" = {
      install_url = moz "styl-us";
      installation_mode = "normal_installed";
      updates_disabled = true;
    };

    "CanvasBlocker@kkapsner.de" = {
      install_url = moz "canvasblocker";
      installation_mode = "normal_installed";
      updates_disabled = true;
    };

    "steam-database@steamdb.info" = {
      install_url = moz "steam-database";
      installation_mode = "normal_installed";
      updates_disabled = true;
    };

    "simplelogin@simplelogin.io" = {
      install_url = moz "simplelogin";
      installation_mode = "normal_installed";
      updates_disabled = true;
    };

    "keepassxc-browser@keepassxc.org" = {
      install_url = moz "keepassxc-browser";
      installation_mode = "normal_installed";
      updates_disabled = true;
    };
  };
  extensionSettings = {
    "keepassxc-browser@keepassxc.org".settings.settings = {
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

  firefoxPolicies = {
    ExtensionSettings = extensions // {
      # Optional: prevent users from installing anything else.
      # "*" = {
      #   installation_mode = "blocked";
      # };
    };

    "3rdparty".Extensions = extensionSettings;
  };
in
{
  hm.programs.floorp.policies = firefoxPolicies;

  hm.programs.firefox.policies = firefoxPolicies;
}
