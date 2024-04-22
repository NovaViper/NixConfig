{
  config,
  lib,
  pkgs,
  ...
}: let
  alejandra-quiet = pkgs.writeShellScriptBin "alejandra-quiet" ''
    alejandra --quiet "$@"
  '';
in {
  home.packages = with pkgs; [
    alejandra-quiet
  ];
}
