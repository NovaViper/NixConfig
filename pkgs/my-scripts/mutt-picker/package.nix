{ pkgs, lib, ... }:
pkgs.writers.writeFishBin "mutt-picker" {
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    "${lib.makeBinPath [ pkgs.fzf ]}"
  ];
} (builtins.readFile ./mutt-picker.fish)
