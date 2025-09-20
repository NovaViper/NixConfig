{
  lib,
  pkgs,
  ...
}:
{
  features.shell = "fish";
  # Make the default shell for users be fish
  users.defaultUserShell = pkgs.fish;

  # Broken for fish so make sure to disable it
  programs.command-not-found.enable = false;

  # Enable NixOS Module
  programs.fish = {
    enable = true;
    # Translate bash scripts to fish
    useBabelfish = true;
  };

  environment.pathsToLink = lib.singleton "/share/fish";

  # Most of the configuration is done in Home-Manager
  hm.programs.fish.enable = true;

  hm.programs.fish.shellInit = lib.concatStringsSep "\n" [
    # fish
    ''
      # Customize cursor
      set fish_cursor_default     block      blink
      set fish_cursor_insert      line       blink
      set fish_cursor_replace_one underscore blink
      set fish_cursor_visual      block

      # set options for plugins
      set sponge_regex_patterns 'password|passwd|^kill'
    ''
  ];
}
