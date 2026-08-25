{ pkgs, ... }:
{
  hm.home.packages = with pkgs; [
    # :editor format
    texliveMedium # LaTex
  ];
}
