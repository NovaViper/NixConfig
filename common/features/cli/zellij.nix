{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hm.programs.zellij;
  hm-config = config.hm;
in {
  hm.programs.zellij.enable = true;

  /*
    hm.programs.zellij.settings = {

  };
  */
}
