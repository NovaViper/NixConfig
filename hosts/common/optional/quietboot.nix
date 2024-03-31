{ config, lib, pkgs, ... }:

{
  boot = {
    plymouth.enable = true;
    consoleLogLevel = 0;
    loader.timeout = 0;
    initrd.verbose = false;
    kernelParams = [ "quiet" ];
  };
}
