{ config, lib, pkgs, ... }: {
  home.packages = with pkgs; [ discord vesktop ];

  /* home.persistence = {
       "/persist/home/novaviper".directories = [ ".config/vesktop" ];
     };
  */
}
