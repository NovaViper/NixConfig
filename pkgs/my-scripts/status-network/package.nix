{ pkgs, lib, ... }:
pkgs.writers.writeFishBin "status-network" {
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
} (builtins.readFile ./network.fish)
