{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.zellij;
in
{
  programs.zellij.enable = true;

  /*
      programs.zellij.settings = {

    };
  */
}
