{
  pkgs,
  config,
  ...
}:
let
  gen-plugin = pkg: {
    name = "${pkg}";
    inherit (pkgs.fishPlugins.${pkg}) src;
  };
in
{
  hm.programs.fish.plugins =
    map gen-plugin ([
      "autopair" # Auto-complete matching pairs in the Fish command line
      "sponge" # Clean fish history from typos automatically
      "done" # Automatically receive notifications when long processes finish
      "puffer" # Text Expansions for Fish
    ])
    ++ [
      {
        name = "fycu";
        #src = "${config.hm.home.homeDirectory}/Documents/Projects/fycu";
        src = pkgs.fetchFromGitHub {
          owner = "NovaViper";
          repo = "fycu";
          # Dev branch
          rev = "dev";
          hash = "sha256-QEMke8U+roPMj9Ewsv4mqgtNCwelEY63EYvDMHxGa4o=";
        };
      }
    ];
}
