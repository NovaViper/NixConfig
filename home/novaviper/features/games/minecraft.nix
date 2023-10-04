{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ prismlauncher-qt5 flite orca ];

  /* home.persistence = {
       "/persist/home/novaviper".directories = [ ".local/share/PrismLauncher" ];
     };
  */
}
