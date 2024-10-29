{
  config,
  lib,
  ...
}:
lib.utilMods.mkModule config "bluetooth" {
  hardware.bluetooth = {
    enable = true;
    # Fix controller compatibility
    input.General = {
      ClassicBondedOnly = false;
      UserspaceHID = false;
    };
  };
}
