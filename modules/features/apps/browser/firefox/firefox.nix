{
  config,
  lib,
  pkgs,
  ...
}: {
  hm.xdg.mimeApps = let
    defaultApplications = {
      "default-web-browser" = ["firefox.desktop"];
      "text/html" = ["firefox.desktop"];
      "x-scheme-handler/http" = ["firefox.desktop"];
      "x-scheme-handler/https" = ["firefox.desktop"];
      "x-scheme-handler/about" = ["firefox.desktop"];
      "x-scheme-handler/unknown" = ["firefox.desktop"];
      "application/xhtml+xml" = ["firefox.desktop"];
      "text/xml" = ["firefox.desktop"];
    };
  in
    lib.mkIf (config.userVars.defaultBrowser == "firefox") {
      enable = true;
      inherit defaultApplications;
      associations.added = defaultApplications;
    };

  hm.programs.firefox.enable = true;

  hm.programs.firefox.nativeMessagingHosts = with pkgs; [fx-cast-bridge];

  hm.programs.firefox.profiles."${config.userVars.username}" = {
    search = {
      force = true;
      default = "ecosia";
    };

    settings = {
      "widget.use-xdg-desktop-portal.file-picker" = 1;
      "browser.disableResetPrompt" = true;
      "browser.download.panel.shown" = true;
      "browser.download.useDownloadDir" = true;
      "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      "browser.shell.checkDefaultBrowser" = true;
      "browser.shell.defaultBrowserCheckCount" = 1;
      "browser.startup.homepage" = "https://google.com";
      "browser.bookmarks.showMobileBookmarks" = true;
      "dom.security.https_only_mode" = true;
      "identity.fxaccounts.enabled" = true;
      "privacy.trackingprotection.enabled" = true;
      "signon.rememberSignons" = false;
      "browser.newtabpage.pinned" = lib.singleton {
        title = "NixOS";
        url = "https://nixos.org";
      };
      "browser.uiCustomization.state" = ''        {"placements":{"widget-overflow-fixed-list":[],"unified-extensions-area":["privacy_privacy_com-browser-action","enhancerforyoutube_maximerf_addons_mozilla_org-browser-action","jid1-93cwpmrbvpjrqa_jetpack-browser-action","sponsorblocker_ajay_app-browser-action","_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action","_25cddbee-458b-4e9f-984d-dbf35511f124_-browser-action","canvasblocker_kkapsner_de-browser-action","_2e5ff8c8-32fe-46d0-9fc8-6b8986621f3c_-browser-action","_74145f27-f039-47ce-a470-a662b129930a_-browser-action","_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action","_cb31ec5d-c49a-4e5a-b240-16c767444f62_-browser-action"],"nav-bar":["back-button","forward-button","stop-reload-button","home-button","firefox-view-button","urlbar-container","fxa-toolbar-menu-button","downloads-button","library-button","keepassxc-browser_keepassxc_org-browser-action","ublock0_raymondhill_net-browser-action","addon_darkreader_org-browser-action","plasma-browser-integration_kde_org-browser-action","_testpilot-containers-browser-action","unified-extensions-button","reset-pbm-toolbar-button","_3c078156-979c-498b-8990-85f7987dd929_-browser-action","browserpass_maximbaz_com-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","ublock0_raymondhill_net-browser-action","_testpilot-containers-browser-action","privacy_privacy_com-browser-action","addon_darkreader_org-browser-action","enhancerforyoutube_maximerf_addons_mozilla_org-browser-action","jid1-93cwpmrbvpjrqa_jetpack-browser-action","keepassxc-browser_keepassxc_org-browser-action","plasma-browser-integration_kde_org-browser-action","sponsorblocker_ajay_app-browser-action","_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action","browserpass_maximbaz_com-browser-action","_25cddbee-458b-4e9f-984d-dbf35511f124_-browser-action","canvasblocker_kkapsner_de-browser-action","_2e5ff8c8-32fe-46d0-9fc8-6b8986621f3c_-browser-action","_3c078156-979c-498b-8990-85f7987dd929_-browser-action","_74145f27-f039-47ce-a470-a662b129930a_-browser-action","_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action","_cb31ec5d-c49a-4e5a-b240-16c767444f62_-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","widget-overflow-fixed-list","unified-extensions-area"],"currentVersion":20,"newElementCount":7}
      '';
    };
  };
}
