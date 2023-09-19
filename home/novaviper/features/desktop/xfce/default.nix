{ config, lib, pkgs, ... }:

{
  imports = [ ../common ];

  #xfconf.settings = {};

  environment.desktop = "xfce";
}
