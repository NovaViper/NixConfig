{
  config,
  lib,
  pkgs,
  ...
}:
let
  hm-config = config.hm;
  cfg = hm-config.programs.zellij;
in
{
  hm.programs.zellij.enable = true;

  /*
      hm.programs.zellij.settings = {

    };
  */
}
