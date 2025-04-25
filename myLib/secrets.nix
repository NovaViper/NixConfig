{
  lib,
  myLib,
  inputs,
  ...
}: let
  # Helper functions we don't plan on exporting past this file
  internals = {
    # Location of the secrets folder in the repo
    secretsPath = builtins.toString inputs.nix-secrets;
  };

  exports = {
    # Helper function for creating secrets for agenix/sops-nix, links the source file given to the user's secrets location
    mkSecretFile = {
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
        sopsFile = internals.secretsPath + "/${myLib.utils.mkPath "sops" (lib.flatten [subDir source])}";
        path = destination;
        inherit owner group format mode neededForUsers restartUnits reloadUnits;
      };

    # Helper functionf or retrieving the location of a user secret
    getUserSecretPath = {
      user ? null,
      path,
    }: let
      baseDir =
        if user != null
        then ["users" user]
        else "users";
    in
      internals.secretsPath + "/${myLib.utils.mkPath "sops" (lib.flatten [baseDir path])}";

    # Helper functionf or retrieving the location of a host secret
    getHostSecretPath = {
      host ? null,
      path,
    }: let
      baseDir =
        if host != null
        then ["hosts" host]
        else "hosts";
    in
      internals.secretsPath + "/${myLib.utils.mkPath "sops" (lib.flatten [baseDir path])}";
  };
in
  exports
