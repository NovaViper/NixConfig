{
  config,
  lib,
  pkgs,
  ...
}:
{
  hardware.sensor.iio.enable = true;
  services.xserver.wacom.enable = true;
}
