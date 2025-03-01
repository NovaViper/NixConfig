{
  config,
  myLib,
  pkgs,
  ...
}: let
  hm-config = config.hm;
in
  myLib.utilMods.mkDesktopModule config "iwd" {
    # Make NetworkManager use iwd
    networking.networkmanager.wifi.backend = "iwd";
  }
