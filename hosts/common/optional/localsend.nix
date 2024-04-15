{
  config,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [localsend];
  # Allow localsend port
  networking.firewall.allowedTCPPorts = [53317];
}
