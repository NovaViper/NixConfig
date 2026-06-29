{
  lib,
  pkgs,
  username,
  ...
}:
let
  printers = with pkgs; [
    hplipWithPlugin
    cnijfilter2
  ];
in
{
  users.users.${username}.extraGroups = lib.singleton "scanner";

  # Address CUPS vulnerability CVE-2024-47076
  systemd.services.cups-browsed.enable = false;

  # Printer Setup
  services.printing = {
    enable = true;
    drivers = printers;
  };

  # Scanner Setup
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ sane-airscan ] ++ printers;
  };

  # Install installation
  environment.systemPackages = printers;
}
