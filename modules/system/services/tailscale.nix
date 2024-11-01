{
  config,
  lib,
  ...
}:
lib.utilMods.mkModule config "tailscale" {
  services.tailscale = {
    enable = true;
    useRoutingFeatures = lib.mkDefault "client";
  };

  networking.firewall = {
    checkReversePath = "loose";
    allowedUDPPorts = [41641]; # Facilitate firewall punching
  };
}