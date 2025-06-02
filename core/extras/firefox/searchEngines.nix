{
  lib,
  pkgs,
  ...
}:
let
  nix-icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";

  searchEngines = {
    ecosia = {
      name = "Ecosia";
      iconMapObj."16" = "https://www.ecosia.org/static/icons/favicon.ico";
      updateInterval = 24 * 60 * 60 * 1000; # Every day
      definedAliases = [
        "@e"
        "@ecosia"
      ];
      urls = lib.singleton { template = "https://www.ecosia.org/search?q={searchTerms}"; };
    };

    nix-packages = {
      iconMapObj."16" = nix-icon;
      name = "Nix Packages";
      definedAliases = lib.singleton "@np";
      urls = lib.singleton {
        template = "https://search.nixos.org/packages?type=packages&query={searchTerms}";
      };
    };

    nixos-opts = {
      iconMapObj."16" = nix-icon;
      name = "NixOS Options";
      definedAliases = lib.singleton "@no";
      urls = lib.singleton {
        template = "https://search.nixos.org/options?type=packages&query={searchTerms}";
      };
    };

    home-opts = {
      iconMapObj."16" = nix-icon;
      name = "Home-Manager Options";
      definedAliases = lib.singleton "@ho";
      urls = lib.singleton {
        template = "https://home-manager-options.extranix.com/?release=master&query={searchTerms}";
      };
    };

    nixos-wiki = {
      iconMapObj."16" = nix-icon;
      name = "NixOS Wiki";
      definedAliases = lib.singleton "@nw";
      urls = lib.singleton { template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; };
    };

    nixpkgs-tracker = {
      iconMapObj."16" = nix-icon;
      name = "Nixpkgs PR Tracker";
      definedAliases = lib.singleton "@nprt";
      urls = lib.singleton { template = "https://nixpk.gs/pr-tracker.html?pr={searchTerms}"; };
    };

    nix-hydra = {
      iconMapObj."16" = nix-icon;
      name = "Nix Hydra Builds";
      definedAliases = lib.singleton "@nh";
      urls = lib.singleton { template = "https://hydra.nixos.org/search?query={searchTerms}"; };
    };

    # All these after all from llakala
    noogle = {
      iconMapObj."16" = nix-icon;
      name = "Noogle";
      definedAliases = lib.singleton "@nog";
      urls = lib.singleton { template = "https://noogle.dev/q?term={searchTerms}"; };
    };

    nixpkgs-search = {
      iconMapObj."16" = "https://github.com/favicon.ico";
      name = "Nixpkgs Search";
      definedAliases = lib.singleton "@npkgs";
      urls = lib.singleton {
        template = "https://github.com/search";
        # Thanks to xunuwu on github for being a reference to use of these functions
        params = lib.attrsToList {
          "type" = "code";
          "q" = "repo:NixOS/nixpkgs lang:nix {searchTerms}";
        };
      };
    };

    github-nix = {
      iconMapObj."16" = "https://github.com/favicon.ico";
      name = "Github Nix Code";
      definedAliases = lib.singleton "@ghn";
      urls = lib.singleton {
        template = "https://github.com/search";
        # Thanks to xunuwu on github for being a reference to use of these functions
        params = lib.attrsToList {
          "type" = "code";
          "q" = "lang:nix NOT is:fork {searchTerms}";
        };
      };
    };
    # Some Extra Stuff
    github-code = {
      iconMapObj."16" = "https://github.com/favicon.ico";
      name = "Github Code";
      definedAliases = lib.singleton "@gh";
      urls = lib.singleton { template = "https://github.com/search?type=code&q={searchTerms}"; };
    };

    github-repo = {
      iconMapObj."16" = "https://github.com/favicon.ico";
      name = "Github Repositories";
      definedAliases = lib.singleton "@ghr";
      urls = lib.singleton { template = "https://github.com/search?type=repositories&q={searchTerms}"; };
    };

    # Social
    youtube = {
      iconMapObj."16" = "https://youtube.com/favicon.ico";
      name = "YouTube";
      definedAliases = [
        "@youtube"
        "@yt"
      ];
      urls = lib.singleton { template = "https://www.youtube.com/results?search_query={searchTerms}"; };
    };
  };
in
{
  hmUser = lib.singleton (
    hm:
    let
      hm-config = hm.config;
    in
    {
      programs.floorp.profiles."${hm-config.home.username}".search.engines = searchEngines;
      programs.firefox.profiles."${hm-config.home.username}".search.engines = searchEngines;
    }
  );
}
