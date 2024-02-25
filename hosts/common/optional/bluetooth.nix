{ config, lib, pkgs, ... }:

{
  hardware.bluetooth = {
    # Enable bluetooth
    enable = true;
    input.General.ClassicBondedOnly = false; # Fix controller compatibility
  };
}
