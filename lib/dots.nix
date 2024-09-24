{outputs, ...}:
with outputs.lib; let
  flakePath = config: "${config.home.sessionVariables.FLAKE}";
  dotsPath = user: "${user}/dotfiles";
in {
  inherit flakePath dotsPath;
  mkDotsSymlink = {
    config,
    user,
    source,
    recursive ? false,
    ...
  }: let
    path = "${flakePath config}/users/${dotsPath user}/${source}";
  in {
    source = config.lib.file.mkOutOfStoreSymlink path;
    inherit recursive;
  };

  getDotsPath = {
    user,
    path,
  }:
    ../users/${dotsPath user}/${path};

  filesIn = path: builtins.attrNames (builtins.readDir path);
}
