{ config, lib, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "thinkknox" = {
        hostname = "192.168.1.159";
        identityFile = "${config.home.homeDirectory}/.ssh/id_ecdsa_sk_rk_knox";
        port = 22;
      };
      "printerpi" = {
        user = "exova";
        hostname = "192.168.1.81";
        port = 22;
      };
    };
  };

  #home.persistence = { "/persist/home/novaviper".directories = [ ".ssh" ]; };
}
