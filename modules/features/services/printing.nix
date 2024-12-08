{
  config,
  myLib,
  pkgs,
  ...
}: let
  printers = with pkgs; [hplipWithPlugin cnijfilter2];
in
  myLib.utilMods.mkModule config "printing" {
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
      extraBackends = with pkgs; [sane-airscan] ++ printers;
    };

    # Install installation
    environment.systemPackages = printers;
  }
