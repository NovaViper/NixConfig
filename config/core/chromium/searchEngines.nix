{
  lib,
  pkgs,
  ...
}:
let
  searchEngines = [
    {
      name = "Nix Packages";
      shortcut = "np";
      url = "https://search.nixos.org/packages?type=packages&query={searchTerms}";
    }

    {
      name = "NixOS Options";
      shortcut = "no";
      url = "https://search.nixos.org/options?type=packages&query={searchTerms}";
    }

    {
      name = "Home-Manager Options";
      shortcut = "ho";
      url = "https://home-manager-options.extranix.com/?release=master&query={searchTerms}";
    }

    {
      name = "NixOS Wiki";
      shortcut = "nw";
      url = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
    }

    {
      name = "Nixpkgs PR Tracker";
      shortcut = "nprt";
      url = "https://nixpk.gs/pr-tracker.html?pr={searchTerms}";
    }

    {
      name = "Nix Hydra Builds";
      shortcut = "nh";
      url = "https://hydra.nixos.org/search?query={searchTerms}";
    }

    # All these after all from llakala
    {
      name = "Noogle";
      shortcut = "nog";
      url = "https://noogle.dev/q?term={searchTerms}";
    }

    {
      name = "Nixpkgs Search";
      shortcut = "npkgs";
      url = "https://github.com/search?q=repo%3ANixOS%2Fnixpkgs%20{searchTerms}&type=code";
    }

    {
      name = "Github Nix Code";
      shortcut = "ghn";
      url = "https://github.com/search?q=lang%3Anix%20NOT%20is%3Afork%20{searchTerms}&type=code";
    }
    # Some Extra Stuff
    {
      name = "Github Code";
      shortcut = "gh";
      url = "https://github.com/search?type=code&q={searchTerms}";
    }

    {
      name = "Github Repositories";
      shortcut = "ghr";
      url = "https://github.com/search?type=repositories&q={searchTerms}";
    }

    # Social
    {
      name = "YouTube";
      shortcut = "yt";
      url = "https://www.youtube.com/results?search_query={searchTerms}";
    }
    {
      name = "ProtonDB";
      shortcut = "pd";
      url = "https://protondb.com/search?q={searchTerms}";
    }
    {
      name = "Reddit";
      shortcut = "red";
      url = "https://old.reddit.com/search?q={searchTerms}&include_over_18=on";
    }
  ];
in
{
  programs.chromium.extraOpts = {
    SiteSearchSettings = searchEngines;
  };
}
