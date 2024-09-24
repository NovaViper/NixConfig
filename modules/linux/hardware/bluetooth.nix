_: {
  hardware.bluetooth = {
    enable = true;
    # Fix controller compatibility
    input.General = {
      ClassicBondedOnly = false;
      UserspaceHID = false;
    };
  };
}
