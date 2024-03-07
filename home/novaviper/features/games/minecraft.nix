{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ prismlauncher-qt5 flite orca ];
}
