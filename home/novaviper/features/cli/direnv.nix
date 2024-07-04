{
  config,
  lib,
  pkgs,
  ...
}: {
  # Shell extension to load and unload environment variables depending on the current directory.
  programs.direnv = {
    enable = true;
    #config = {};
    nix-direnv.enable = true;
  };
}
