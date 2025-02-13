{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: let
  cfg = config.hm.programs.zellij;
  hm-config = config.hm;
in
  myLib.utilMods.mkModule config "zellij" {
    hm.programs.zellij.enable = true;

    /*
      hm.programs.zellij.settings = {

    };
    */
  }
