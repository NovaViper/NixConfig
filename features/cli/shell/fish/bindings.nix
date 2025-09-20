{ lib, ... }:
{
  hm.programs.fish.shellInit =
    # fish
    ''
      # Use vim bindings and cursors
      set -g fish_key_bindings fish_vi_key_bindings

      # Ctrl+Z to resume, in functions.nix, I have a special function to keep it from repainting the screen
      bind --mode insert \cz 'fg 2>/dev/null'

      # tab-completion with search
      bind --mode insert \t complete-and-search
      bind --mode visual \t complete-and-search
    '';

  hm.programs.fish.interactiveShellInit =
    lib.mkOrder 400 # fish
      ''
        # Helper function for Ctrl+Z suspend, from https://github.com/llakala/nixos/blob/981587a31a2020a0cd92c48f7ba2d158120581f6/apps/core/fish/suspend.nix#L13
        # Don't ask me how this works, I have no clue! But it means repeatedly
        # pressing Ctrl+Z to suspend and unsuspend doesn't create a new line every
        # time - which is wonderful. Thanks to krobelus on Matrix for the snippet!

        # Also note that this does leave the first part of the command in your title
        # when running multiple times - but that's a Fish bug I've had forever, and
        # I'll accept it if it means we don't have to deal with constant repaints.
        functions --copy fish_job_summary job_summary
        function fish_job_summary
          if contains STOPPED $argv
            return
          end
          job_summary $argv
        end
      '';
}
