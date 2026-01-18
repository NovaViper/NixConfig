{ pkgs, wrapPackage }:
wrapPackage (
  {
    config,
    wlib,
    lib,
    ...
  }:
  {
    inherit pkgs;
    package = pkgs.stylua;
    flags = {
      "--indent-type" = "Spaces";
      "--indent-width" = "2";
      "--collapse-simple-statement" = "Always";
    };
  }
)
