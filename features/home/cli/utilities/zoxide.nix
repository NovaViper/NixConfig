{
  config,
  lib,
  pkgs,
  ...
}: {
  # smart cd command, inspired by z and autojump
  programs.zoxide.enable = true;
}
