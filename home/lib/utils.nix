{
  config,
  pkgs,
  ...
}: let
  ooss = config.lib.file.mkOutOfStoreSymlink;

  flakePath = "${config.home.sessionVariables.FLAKE}";

  linkDots = path: ooss "${flakePath}/home/${config.home.username}/dotfiles/${path}";

  filesIn = path: builtins.attrNames (builtins.readDir path);
in {
  inherit flakePath linkDots filesIn;
}
