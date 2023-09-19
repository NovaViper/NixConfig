{ config, lib, pkgs, ... }:

{
  programs.mpv = {
    enable = true;
    #bindings = { };
    config = { };
  };
}
