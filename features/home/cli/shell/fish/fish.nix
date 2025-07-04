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
  };

  programs.fish.shellInit = lib.concatStringsSep "\n" [
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

  programs.fish.interactiveShellInit =
    # fish
    ''
      # Helper function for Ctrl+Z suspend, from https://github.com/llakala/nixos/blob/981587a31a2020a0cd92c48f7ba2d158120581f6/apps/core/fish/suspend.nix#L13
      # Don't ask me how this works, I have no clue! But it means repeatedly
      # pressing Ctrl+Z to suspend and unsuspend doesn't create a new line every
      # time - which is wonderful. Thanks to krobelus on Matrix for the snippet!

      # Also note that this does leave the first part of the command in your title
      # when running multiple times - but that's a Fish bug I've had forever, and
      # I'll accept it if it means we don't have to deal with constant repaints.
      functions --copy fish_job_summary job_summary
    '';

  programs.fish.functions = {
    fish_job_summary.body = ''
      if contains STOPPED $argv
        return
      end
      job_summary $argv
    '';
  };
}
