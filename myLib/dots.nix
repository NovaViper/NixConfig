{
  lib,
  flakePath,
  dotsPath,
  ...
}:
{
  # Helper function for creating Out of Store symlinks for, links the source file given to the user's dotfiles location
  mkDotsSymlink =
    {
      config,
      source,
      recursive ? false,
      ...
    }:
    let
      cfg = if config ? hm then config.hm else config;
      path = "${flakePath cfg}/home/${dotsPath}/${source}";
    in
    {
      source = cfg.lib.file.mkOutOfStoreSymlink path;
      inherit recursive;
    };

  # Helper function for retrieving the location of the user's dotfiles path
  getDotsPath = path: ../home/${dotsPath}/${path};

  # Helper function for retrieving all files in a given path
  filesIn = path: builtins.attrNames (builtins.readDir path);
}
