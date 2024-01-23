{ pkgs, ... }:

{
  nova = pkgs.callPackage ./nova { };
}
