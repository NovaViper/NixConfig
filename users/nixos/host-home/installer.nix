{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
{
  #imports = lib.singleton ./base.nix;
  imports = myLib.slimports {
    paths = lib.singleton ./shared;
  };

  #home.packages = with pkgs; [digikam];
}
