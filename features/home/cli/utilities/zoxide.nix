{
  config,
  lib,
  pkgs,
  ...
}: {
  # smart cd command, inspired by z and autojump
  hm.programs.zoxide.enable = true;
}
