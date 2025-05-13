{ inputs, lib, ... }:

{
  imports = lib.singleton inputs.disko.nixosModules.disko;
}
