{
  config,
  pkgs,
  ...
}: let
  ooss = config.lib.file.mkOutOfStoreSymlink;

  flakePath = "${config.home.sessionVariables.FLAKE}";

  dotsPath = "${config.home.username}/dotfiles";

  agePath = ../../secrets;

  linkDots = path: ooss "${flakePath}/home/${dotsPath}/${path}";

  refDots = path: ../${dotsPath}/${path};

  refUserAge = path: "${agePath}/${config.home.username}/${path}";

  refAgeID = path: "${agePath}/identities/${path}";

  esecrets = builtins.fromJSON (builtins.readFile (refUserAge "eval-secrets.json"));

  filesIn = path: builtins.attrNames (builtins.readDir path);
in {
  inherit flakePath linkDots refDots esecrets refUserAge refAgeID filesIn;
}
