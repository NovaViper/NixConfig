{ config, lib, pkgs, ... }:

{
  programs.atuin = {
    enable = true;
    settings = {
      sync_frequency = "10m";
      inline_height = 16;
      keymap_mode = "vim-insert";
      keymap_cursor = {
        emacs = "blink-block";
        vim_insert = "blink-bar";
        vim_normal = "steady-block";
      };
      enter_accept = true;
      history_filter = [ "^gpg .*--edit-key=.+" "^gpg .*--recipient.+" ];
    };
  };
}
