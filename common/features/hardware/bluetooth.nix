{config, ...}: {
  hardware.bluetooth.enable = true;

  # Fix controller compatibility
  hardware.bluetooth.input.General = {
    ClassicBondedOnly = false;
    UserspaceHID = false;
  };
}
