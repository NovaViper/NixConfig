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

  esecrets = builtins.fromJSON (builtins.readFile ../${dotsPath}/secrets/eval-secrets.json);

  filesIn = path: builtins.attrNames (builtins.readDir path);
in {
  inherit flakePath linkDots refDots esecrets filesIn;
}
