{
  config,
  lib,
  pkgs,
  ...
}:
lib.utilMods.mkModule config "rust" {
  home.packages = with pkgs; [rustup];
}
