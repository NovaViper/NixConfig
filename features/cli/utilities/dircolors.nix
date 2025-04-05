{
  config,
  lib,
  pkgs,
  ...
}: {
  # Custom colors for ls, grep and more
  hm.programs.dircolors.enable = true;
}
