{ config, lib, pkgs, ... }:

{
  boot = {
    plymouth.enable = true;
    loader.timeout = 0;
    kernelParams = [
      "quiet"
      "loglevel=3"
      "systemd.show_status=auto"
      "udev.log_level=3"
      "rd.udev.log_level=3"
      "vt.global_cursor_default=0"
    ];
    consoleLogLevel = 0;
    initrd.verbose = false;
  };
}
