{ config, lib, pkgs, ... }: {

  home.packages = with pkgs; [ discord ];

  /* home.persistence = {
       "/persist/home/novaviper".directories = [ ".config/discord" ];
     };
  */
}
