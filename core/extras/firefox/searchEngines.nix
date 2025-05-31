{
  config,
  lib,
  pkgs,
  ...
}:
let
  nix-icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";

  searchEngines = {
    ecosia = {
      name = "Ecosia";
      icon = "https://www.ecosia.org/static/icons/favicon.ico";
      updateInterval = 24 * 60 * 60 * 1000; # Every day
      definedAliases = [
        "@e"
        "@ecosia"
      ];
      urls = lib.singleton { template = "https://www.ecosia.org/search?q={searchTerms}"; };
    };

    nix-packages = {
      icon = nix-icon;
      name = "Nix Packages";
      definedAliases = lib.singleton "@np";
      urls = lib.singleton {
        template = "https://search.nixos.org/packages?type=packages&query={searchTerms}";
      };
    };

    nixos-opts = {
      icon = nix-icon;
      name = "NixOS Options";
      definedAliases = lib.singleton "@no";
      urls = lib.singleton {
        template = "https://search.nixos.org/options?type=packages&query={searchTerms}";
      };
    };

    home-opts = {
      icon = nix-icon;
      name = "Home-Manager Options";
      definedAliases = "@ho";
      urls = lib.singleton {
        template = "https://home-manager-options.extranix.com/?release=master&query={searchTerms}";
      };
    };

    nixos-wiki = {
      icon = nix-icon;
      name = "NixOS Wiki";
      definedAliases = lib.singleton "@nw";
      urls = lib.singleton { template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; };
    };

    nixpkgs-tracker = {
      icon = nix-icon;
      name = "Nixpkgs PR Tracker";
      definedAliases = [ "@nprt" ];
      urls = lib.singleton { template = "https://nixpk.gs/pr-tracker.html?pr={searchTerms}"; };
    };

    nix-hydra = {
      icon = nix-icon;
      name = "Nix Hydra Builds";
      definedAliases = "@nh";
      url = lib.singleton { template = "https://hydra.nixos.org/search?query={searchTerms}"; };
    };

    # All these after all from llakala
    noogle = {
      icon = nix-icon;
      name = "Noogle";
      definedAliases = [ "@nog" ];
      urls = lib.singleton { template = "https://noogle.dev/q?term={searchTerms}"; };
    };

    nixpkgs-search = {
      icon = "https://github.com/favicon.ico";
      name = "Nixpkgs Search";
      definedAliases = [ "@npkgs" ];
      urls = lib.singleton {
        template = "https://github.com/search";
        # Thanks to xunuwu on github for being a reference to use of these functions
        params = lib.attrsToList {
          "type" = "code";
          "q" = "repo:NixOS/nixpkgs lang:nix {searchTerms}";
        };
      };
    };

    git-nix = {
      icon = "https://github.com/favicon.ico";
      name = "Github Nix Code";
      definedAliases = [ "@ghn" ];
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
      definedAliases = [ "@ghr" ];
      name = "Github Code";
      urls = lib.singleton { template = "https://github.com/search?type=code&q={searchTerms}"; };
    };

    github-repo = {
      definedAliases = [ "@gh" ];
      name = "Github Code";
      urls = lib.singleton { template = "https://github.com/search?type=repositories&q={searchTerms}"; };
    };

    # Social
    youtube = {
      name = "YouTube";
      definedAliases = [ "@yt" ];
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
