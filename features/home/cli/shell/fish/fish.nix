{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
{
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
  };
}
