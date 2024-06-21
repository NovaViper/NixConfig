{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.direnv = {
    enable = true;
    #config = {};
    nix-direnv.enable = true;
  };
}
