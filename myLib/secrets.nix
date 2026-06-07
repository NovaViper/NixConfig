{
  lib,
  myLib,
  inputs,
  ...
}:
let
  # Helper functions we don't plan on exporting past this file
  internals = {
    # Location of the secrets folder in the repo
    secretsPath = toString inputs.nix-secrets;
  };

  exports = {
    # Helper function for creating secrets for sops-nix, links the source file given to the user's secrets location
    mkSecretFile =
      {
        subDir ? null,
        source,
        destination ? null,
        format ? null,
        owner ? null,
        group ? null,
        mode ? null,
        neededForUsers ? null,
        restartUnits ? null,
        reloadUnits ? null,
        ...
      }:
      # Remove any null values or they will cause values to be overwritten when they don't need to be!
      lib.filterAttrs (n: v: v != null) {
        sopsFile =
          internals.secretsPath
          + "/${
            myLib.utils.mkPath "sops" (
              lib.flatten [
                subDir
                source
              ]
            )
          }";
        path = destination;
        inherit
          owner
          group
          format
          mode
          neededForUsers
          restartUnits
          reloadUnits
          ;
      };
  };
in
exports
