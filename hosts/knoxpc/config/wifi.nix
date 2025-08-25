{ lib, ... }:
{
  networking.wireless.enable = true;

  hardware.bluetooth.input.General = lib.mkForce { };
}
