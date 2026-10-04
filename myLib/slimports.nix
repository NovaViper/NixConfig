{
  lib,
  myLib,
  ...
}:
let
  importOptionalPaths =
    paths:
    lib.flatten (
      map (path: if lib.pathExists path then myLib.utils.listNixFilesForPath path else [ ]) paths
    );

  # The actually exported function
  finalFunc =
    {
      paths ? [ ],
      optionalPaths ? [ ],
    }:
    myLib.utils.importPaths paths ++ importOptionalPaths optionalPaths;
in
finalFunc
