{ pkgs, lib, ... }:
pkgs.writers.writeFishBin "status-cpu-ram" {
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    "${lib.makeBinPath (
      with pkgs;
      [
        coreutils
        networkmanager
      ]
    )}"
  ];
} (builtins.readFile ./cpu-ram.fish)
