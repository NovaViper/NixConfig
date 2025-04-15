{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: {
  imports = [./fishAbbr.nix];
  features.shell = "fish";

  programs.fish = {
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
