{ pkgs, writeShellApplication, ... }:
writeShellApplication {
  name = "load-resident-key";

  runtimeInputs = with pkgs; [
    bash
    yubikey-manager
  ];

  text = builtins.readFile ./resident-key-download.sh;
}
