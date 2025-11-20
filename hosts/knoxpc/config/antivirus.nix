{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Enable Anti-virus
  services.clamav = {
    daemon.enable = true;
    scanner.enable = true;
    updater.enable = true;
    fangfrisch.enable = true;
  };
}
