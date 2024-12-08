{
  lib,
  myLib,
  ...
}: {
  # Helper function for creating Out of Store symlinks for, links the source file given to the user's dotfiles location
  mkDotsSymlink = {
    config,
    user,
    source,
    recursive ? false,
    ...
  }: let
    path = "${myLib.flakePath config}/users/${myLib.dotsPath user}/${source}";
  in {
    source = config.lib.file.mkOutOfStoreSymlink path;
    inherit recursive;
  };

  # Helper function for retrieving the location of the user's dotfiles path
  getDotsPath = {
    user,
    path,
  }:
    ../users/${myLib.dotsPath user}/${path};

  # Helper function for retrieving all files in a given path
  filesIn = path: builtins.attrNames (builtins.readDir path);
}
