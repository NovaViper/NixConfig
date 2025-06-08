{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.fish.shellInit =
    # fish
    ''
      # Use vim bindings and cursors
      set -g fish_key_bindings fish_vi_key_bindings

      # Ctrl+Z to resume, in functions.nix, I have a special function to keep it from repainting the screen
      bind --mode insert \cz fg 2>/dev/null

      # tab-completion with search
      bind --mode insert \t complete-and-search
      bind --mode visual \t complete-and-search
    '';
}
