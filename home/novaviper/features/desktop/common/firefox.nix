{ inputs, config, lib, pkgs, ... }: {
  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };

  home.sessionVariables.BROWSER = "firefox";

  programs.firefox = {
    enable = true;
    nativeMessagingHosts = with pkgs; [ fx-cast-bridge keepassxc ];
    profiles.novaviper = {
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        #sponsorblock
        #return-youtube-dislikes
        #darkreader
        bypass-paywalls-clean
        #plasma-integration
        #enhancer-for-youtube
        #keepassxc-browser
        #indie-wiki-buddy
        #stylus
        #canvasblocker
      ];
      bookmarks = { };
      search = {
        force = true;
        default = "Google";
        engines = {
          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                {
                  name = "type";
                  value = "packages";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }];
            icon =
              "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
          "NixOS Options" = {
            urls = [{
              template = "https://search.nixos.org/options";
              params = [
                {
                  name = "type";
                  value = "packages";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }];
            icon =
              "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };

          "NixOS Wiki" = {
            urls = [{
              template = "https://nixos.wiki/index.php?search={searchTerms}";
            }];
            iconUpdateURL = "https://nixos.wiki/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = [ "@nw" ];
          };
        };
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
        "browser.newtabpage.pinned" = [{
          title = "NixOS";
          url = "https://nixos.org";
        }];
        "browser.uiCustomization.state" = ''
          {"placements":{"widget-overflow-fixed-list":[],"unified-extensions-area":["privacy_privacy_com-browser-action","enhancerforyoutube_maximerf_addons_mozilla_org-browser-action","jid1-93cwpmrbvpjrqa_jetpack-browser-action","keepassxc-browser_keepassxc_org-browser-action","sponsorblocker_ajay_app-browser-action","_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action"],"nav-bar":["back-button","forward-button","stop-reload-button","home-button","firefox-view-button","urlbar-container","fxa-toolbar-menu-button","downloads-button","library-button","keepassxc-browser_keepassxc_org-browser-action","ublock0_raymondhill_net-browser-action","addon_darkreader_org-browser-action","plasma-browser-integration_kde_org-browser-action","_testpilot-containers-browser-action","unified-extensions-button"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","ublock0_raymondhill_net-browser-action","_testpilot-containers-browser-action","privacy_privacy_com-browser-action","addon_darkreader_org-browser-action","enhancerforyoutube_maximerf_addons_mozilla_org-browser-action","jid1-93cwpmrbvpjrqa_jetpack-browser-action","keepassxc-browser_keepassxc_org-browser-action","plasma-browser-integration_kde_org-browser-action","sponsorblocker_ajay_app-browser-action","_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","widget-overflow-fixed-list","unified-extensions-area"],"currentVersion":19,"newElementCount":7}
        '';
      };
      userChrome = "";
    };
  };
}
