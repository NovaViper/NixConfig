{
  lib,
  pkgs,
  ...
}: let
  nix-icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
in {
  "Ecosia" = {
    iconUpdateURL = "https://www.ecosia.org/static/icons/favicon.ico";
    updateInterval = 24 * 60 * 60 * 1000; # Every day
    definedAliases = ["@e" "@ecosia"];
    urls = lib.singleton {template = "https://www.ecosia.org/search?q={searchTerms}";};
  };

  "Nix Packages" = {
    inherit nix-icon;
    definedAliases = lib.singleton "@np";
    urls = lib.singleton {template = "https://search.nixos.org/packages?type=packages&query={searchTerms}";};
  };

  "NixOS Options" = {
    inherit nix-icon;
    definedAliases = lib.singleton "@no";
    urls = lib.singleton {template = "https://search.nixos.org/options?type=packages&query={searchTerms}";};
  };

  "NixOS Wiki" = {
    inherit nix-icon;
    definedAliases = lib.singleton "@nw";
    urls = lib.singleton {template = "https://wiki.nixos.org/w/index.php?search={searchTerms}";};
  };

  "Nixpkgs PR Tracker" = {
    inherit nix-icon;
    definedAliases = ["@nprt"];
    urls = lib.singleton {template = "https://nixpk.gs/pr-tracker.html?pr={searchTerms}";};
  };

  # All these after all from llakala
  "Noogle" = {
    inherit nix-icon;
    definedAliases = ["@nog"];
    urls = lib.singleton {template = "https://noogle.dev/q?term={searchTerms}";};
  };

  "Nixpkgs" = {
    iconUpdateURL = "https://github.com/favicon.ico";
    definedAliases = ["@npkgs"];
    urls = lib.singleton {
      template = "https://github.com/search";
      # Thanks to xunuwu on github for being a reference to use of these functions
      params = lib.attrsToList {
        "type" = "code";
        "q" = "repo:NixOS/nixpkgs lang:nix {searchTerms}";
      };
    };
  };

  "Github Nix Code" = {
    iconUpdateURL = "https://github.com/favicon.ico";
    definedAliases = ["@ghn"];
    urls = lib.singleton {
      template = "https://github.com/search";
      # Thanks to xunuwu on github for being a reference to use of these functions
      params = lib.attrsToList {
        "type" = "code";
        "q" = "lang:nix NOT is:fork {searchTerms}";
      };
    };
  };
}
