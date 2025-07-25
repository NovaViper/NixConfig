{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Enable Anti-virus
  services.clamav = {
    scanner.enable = true;
    updater.enable = true;
    fangfrisch.enable = true;
  };
}
