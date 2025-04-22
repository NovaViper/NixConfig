{
  lib,
  self,
  myLib,
  inputs,
  ...
}: let
  # Helper functions we don't plan on exporting past this file
  internals = {
    # Location of the secrets folder in the external repo
    secretsPath = (builtins.toString inputs.nix-secrets) + "/secrets";
  };

  exports = {
    # Helper function for creating secrets for agenix/sops-nix, links the source file given to the user's secrets location
    mkSecretFile = {
      user,
      source,
      destination ? null,
      owner ? null,
      group ? null,
      mode ? null,
      ...
    }:
    # Remove any null values or they will cause values to be overwritten when they don't need to be!
      lib.filterAttrs (n: v: v != null) {
        rekeyFile = internals.secretsPath + "/${user}/${source}";
        path = destination;
        inherit owner group mode;
      };

    # Helper functionf or retrieving the location of the user's secrets path
    getSecretPath = {
      user,
      path,
    }:
      internals.secretsPath + "/${user}/${path}";

    # Helper function for adding identity files located in the age path
    mkSecretIdentities = identities: builtins.map (x: internals.secretsPath + "/identities/${x}") identities;

    # Helper function for retrieving the path to the rekeyed secrets for agenix-rekey local mode
    getRekeyedPath = path: internals.secretsPath + "/rekeyed/${path}";

    # Helper function for retrieving the eval-secrets.json for the specified user
    #evalSecret = user: builtins.fromJSON (builtins.readFile "${internals.secretsPath}/${user}/eval-secrets.json");
  };
in
  exports
