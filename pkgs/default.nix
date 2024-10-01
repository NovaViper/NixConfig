# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs ? import <nixpkgs> {}, ...}: rec {
  # example = pkgs.callPackage ./example { };
  alvr = pkgs.callPackage ./alvr {};
  oh-my-posh = pkgs.callPackage ./oh-my-posh {};
  plasma-panel-spacer-extended = pkgs.callPackage ./plasma-panel-spacer-extended {};
  plasma-window-title-applet = pkgs.callPackage ./plasma-window-title-applet {};
  restart-plasma = pkgs.callPackage ./restart-plasma {};
}
