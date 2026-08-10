{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    proton-vpn
    proton-vpn-cli
  ];

  services.ivpn.enable = true;
}
