{
  config,
  lib,
  ...
}:
lib.utilMods.mkModule config "bluetooth" {
  hardware.bluetooth.enable = true;

  # Fix controller compatibility
  hardware.bluetooth.input.General = {
    ClassicBondedOnly = false;
    UserspaceHID = false;
  };
}
