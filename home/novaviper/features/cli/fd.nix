{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.fd = {
    enable = true;
    hidden = true;
    ignores = [".git/" "*.bak"];
  };
}
