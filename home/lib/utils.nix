{
  config,
  pkgs,
  ...
}: let
  ooss = config.lib.file.mkOutOfStoreSymlink;

  flakePath = "${config.home.sessionVariables.FLAKE}";

  linkDots = path: ooss "${flakePath}/home/${config.home.username}/dots/${path}";

  filesIn = path: builtins.attrNames (builtins.readDir path);
in {
  inherit flakePath linkDots filesIn;
}
