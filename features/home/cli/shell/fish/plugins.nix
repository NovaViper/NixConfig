{
  config,
  lib,
  pkgs,
  ...
}:
let
  gen-plugin = pkg: {
    name = "${pkg}";
    inherit (pkgs.fishPlugins.${pkg}) src;
  };
in
{
  programs.fish.plugins = map gen-plugin [
    "autopair" # Auto-complete matching pairs in the Fish command line
    "sponge" # Clean fish history from typos automatically
    "done" # Automatically receive notifications when long processes finish
    "puffer" # Text Expansions for Fish
  ];
}
