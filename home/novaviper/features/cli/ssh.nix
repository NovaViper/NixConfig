{ config, lib, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "thinkknox" = {
        hostname = "192.168.1.159";
        identityFile = "${config.home.homeDirectory}/.ssh/id_ecdsa_sk";
        port = 22;
      };
    };
  };
}
