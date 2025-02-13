{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: let
  hm-config = config.hm;
in
  {imports = [./fishAbbr.nix];}
  // myLib.utilMods.mkModule config "fish" {
    # Make the default shell for users be fish
    users.defaultUserShell = pkgs.fish;

    programs.command-not-found.enable = false; # Broken

    # Enable NixOS module
    programs.fish = {
      enable = true;
      # Translate bash scripts to fish
      useBabelfish = true;
    };

    environment.pathsToLink = ["/share/fish"];

    # Most of the configuration is done in Home-Manager
    # Enable accompanying modules
    modules.atuin.enable = true;
    modules.oh-my-posh.enable = true;

    hm.programs.fish = {
      enable = true;
      shellInit = lib.concatStringsSep "\n" [
        ''
          # Use vim bindings and cursors
          set -g fish_key_bindings fish_vi_key_bindings
          set fish_cursor_default     block      blink
          set fish_cursor_insert      line       blink
          set fish_cursor_replace_one underscore blink
          set fish_cursor_visual      block
        ''
      ];
      plugins = [
        {
          name = "autopair";
          src = pkgs.fishPlugins.autopair.src;
        }
        {
          name = "fzf.fish";
          src = pkgs.fishPlugins.fzf-fish.src;
        }
        {
          name = "pufferfish";
          src = pkgs.fishPlugins.puffer.src;
        }
        {
          name = "done";
          src = pkgs.fishPlugins.done.src;
        }
      ];
    };
  }
