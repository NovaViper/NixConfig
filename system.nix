let
  sources = import ./extra/npins;
  pkgs = import sources.nixpkgs { config.allowUnfree = true; }; # Read impurely from `builtins.currentSystem`
  #nixosSystem = import "${sources.nixpkgs}/nixos/lib/eval-config.nix";

  #myLib = import ./extra/myLib/default.nix { inherit pkgs; };

in
{

}
