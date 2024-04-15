{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.atuin = {
    enable = true;
    #flags = [ ];
    settings = {
      sync_frequency = "10m";
      inline_height = 16;
      keymap_mode = "auto";
      enter_accept = true;
    };
  };
}
