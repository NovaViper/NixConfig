flake @ {outputs, ...}:
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
  }: {
    source = config.lib.file.mkOutOfStoreSymlink "${flakePath config}/users/${dotsPath user}/${source}";
    recursive = recursive;
  };

  getDotsPath = {
    user,
    path,
  }:
    ../users/${dotsPath user}/${path};

  filesIn = path: builtins.attrNames (builtins.readDir path);
}
