{
  config,
  lib,
  pkgs,
  ...
}: {
  # Fancy 'find' replacement
  hm.programs.fd = {
    enable = true;
    hidden = true;
    ignores = [".git/" "*.bak"];
  };
}
