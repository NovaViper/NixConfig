{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ moonlight-qt ];

  networking.firewall = {
    allowedTCPPortRanges = [{
      from = 47984;
      to = 48010;
    }];
    allowedUDPPortRanges = [{
      from = 47998;
      to = 48010;
    }];
  };
}
