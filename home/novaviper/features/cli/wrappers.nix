{
  config,
  lib,
  pkgs,
  ...
}:
# Wrappers for various uses
let
  alejandra-quiet = pkgs.writeShellScriptBin "alejandra-quiet" ''
    alejandra --quiet "$@"
  '';
in {
  home.packages = with pkgs; [
    alejandra-quiet
  ];
}
