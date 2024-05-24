{
  config,
  pkgs,
  ...
}: let
  ooss = config.lib.file.mkOutOfStoreSymlink;

  flakePath = "${config.home.sessionVariables.FLAKE}";

  dotsPath = "${config.home.username}/dotfiles";

  linkDots = path: ooss "${flakePath}/home/${dotsPath}/${path}";

  refDots = path: ../${dotsPath}/${path};

  filesIn = path: builtins.attrNames (builtins.readDir path);
in {
  inherit flakePath linkDots refDots filesIn;
}
