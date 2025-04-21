{
  lib,
  self,
  myLib,
  ...
}: let
  # Helper functions we don't plan on exporting past this file
  internals = {
    # Location of the secrets folder in the repo
    agePath = ../secrets;

    getListOfHMSecretIdentities = config: lib.mapAttrsToList (user: hmConfig: hmConfig.userVars.userIdentityPaths) config.home-manager.users;
    flattenSecretIdentities = config: (lib.flatten (internals.getListOfHMSecretIdentities config));
  };

  exports = {
    # Helper function for creating secrets for agenix/sops-nix, links the source file given to the user's secrets location
    mkSecretFile = {
      user,
      source,
      destination ? null,
      owner ? null,
      group ? null,
      ...
    }:
    # Remove any null values or they will cause values to be overwritten when they don't need to be!
      lib.filterAttrs (n: v: v != null) {
        #file = lib.path.append (internals.agePath + "/${user}") source;
        rekeyFile = internals.agePath + "/${user}/${source}";
        path = destination;
        inherit owner group;
      };

    # Helper function for adding identity files located in the age path
    #mkSecretIdentities = identity: lib.lists.forEach identity (x: lib.path.append (internals.agePath + "/identities") x);
    mkSecretIdentities = identities: builtins.map (x: internals.agePath + "/identities/${x}") identities;

    getSecretIdentitiesList = config: lib.toList (builtins.toString (internals.flattenSecretIdentities config));

    # Helper function for retrieving the eval-secrets.json for the specified user
    evalSecret = user: builtins.fromJSON (builtins.readFile "${internals.agePath}/${user}/eval-secrets.json");
  };
in
  exports
