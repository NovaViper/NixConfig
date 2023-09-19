{ config, lib, pkgs, ... }:

{

  services.syncthing = {
    enable = true;
    tray = {
      enable = true;
      package = pkgs.syncthingtray;
      command = "syncthingtray";
    };
  };

  #home.persistence = { "/persist/home/novaviper".directories = [ "Sync" ]; };
}
