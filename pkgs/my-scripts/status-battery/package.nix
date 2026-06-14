{ pkgs, lib, ... }:
pkgs.writers.writeFishBin "status-battery" {
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    "${lib.makeBinPath [ pkgs.coreutils ]}"
  ];
} (builtins.readFile ./battery.fish)
