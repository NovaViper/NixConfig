{
  config,
  lib,
  pkgs,
  ...
}:
{
  # A bunch of extra packages too small for their own file
  hm.home.packages = with pkgs; [
    # Fancy utilities
    timer # Cooler timer in terminal
    tldr # better man pages
    entr # run commands when files change!
    procs # Better ps
    dust # Better du and df
  ];
}
