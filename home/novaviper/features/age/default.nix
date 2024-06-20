{
  config,
  lib,
  pkgs,
  inputs,
  options,
  ...
}: let
  utils = import ../../../lib/utils.nix {inherit config pkgs;};
in {
  imports = with inputs; [agenix.homeManagerModules.default];
  age = {
    identityPaths =
      [
        (utils.refAgeID "age-yubikey-identity-a38cb00a-usba.txt")
        #(utils.refAgeID "age-yubikey-identity-ID-INTERFACE.txt")
      ]
      ++ options.age.identityPaths.default;
  };
}
