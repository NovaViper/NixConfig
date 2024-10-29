{
  config,
  lib,
  pkgs,
  name,
  ...
}:
lib.utilMods.mkModule config "floorp" {
  xdg.mimeApps = lib.mkIf (config.variables.defaultBrowser == "floorp") rec {
    enable = true;
    defaultApplications = {
      "default-web-browser" = ["floorp.desktop"];
      "text/html" = ["floorp.desktop"];
      "x-scheme-handler/http" = ["floorp.desktop"];
      "x-scheme-handler/https" = ["floorp.desktop"];
      "x-scheme-handler/about" = ["floorp.desktop"];
      "x-scheme-handler/unknown" = ["floorp.desktop"];
      "application/xhtml+xml" = ["floorp.desktop"];
      "text/xml" = ["floorp.desktop"];
    };
    associations.added = defaultApplications;
  };

  #home.packages = with pkgs; [floorp];
  programs.floorp = {
    enable = true;
    package = pkgs.floorp;
    nativeMessagingHosts = with pkgs; [fx-cast-bridge];
    profiles."${name}" = {
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
      search = {
        force = true;
        default = "Ecosia";
        engines = {
          "Ecosia" = {
            urls = [{template = "https://www.ecosia.org/search?q={searchTerms}";}];
            iconUpdateURL = "https://www.ecosia.org/static/icons/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000; # Every day
            definedAliases = ["@e" "@ecosia"];
          };
          "Nix Packages" = {
            urls = [
              {
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
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@np"];
          };
          "NixOS Options" = {
            urls = [
              {
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
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@no"];
          };
          "NixOS Wiki" = {
            urls = [{template = "https://wiki.nixos.org/w/index.php?search={searchTerms}";}];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = ["@nw"];
          };
        };
      };
    };
  };
}
