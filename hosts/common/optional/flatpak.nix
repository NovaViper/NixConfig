{ config, lib, pkgs, ... }:

{
  # Enable Flatpak
  services.flatpak.enable = true;

  # Create folder where all fonts are linked to /run/current-system/sw/share/X11/fonts
  fonts.fontDir.enable = true;
}
