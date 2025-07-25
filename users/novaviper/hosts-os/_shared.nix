{
  config,
  lib,
  myLib,
  pkgs,
  inputs,
  ...
}:
let
  myself = "novaviper";
in
{
  users.users.${myself} = {
    extraGroups = [
      "video"
      "audio"
      "scanner"
      "gamemode"
      "libvirtd"
    ];
  };
}
