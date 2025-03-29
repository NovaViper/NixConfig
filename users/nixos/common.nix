{
  config,
  lib,
  myLib,
  pkgs,
  inputs,
  ...
}: let
  hm-config = config.hm;
  myself = "nixos";
in {
  imports = myLib.utils.concatImports {
    paths =
      # Terminal Utils
      myLib.utils.importFromPath {
        path = ../../common/features/cli;
        dirs = ["shell/fish"];
        files = ["bat" "btop" "fastfetch" "git" "shell-utils"];
      }
      ++ myLib.utils.importFromPath {
        path = ../../common/features;
        #dirs = ["editor/doom-emacs"];
        files = ["terminal/ghostty" "locales/us-english" "browser/firefox/floorp"];
      }
      # Development Environment
      ++ myLib.utils.importFromPath {
        path = ../../common/features/development;
        files = ["nix"];
      };
  };

  # Force atuin off
  hm.programs.atuin.enable = lib.mkForce false;

  userVars = {
    username = "nixos";

    defaultTerminal = "ghostty";
    defaultBrowser = "floorp";
  };
}
