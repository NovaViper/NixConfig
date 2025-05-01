{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    libnotify
    clamtk
  ];

  # Enable Anti-virus
  services.clamav = {
    scanner.enable = true;
    updater.enable = true;
    fangfrisch.enable = true;
  };
}
