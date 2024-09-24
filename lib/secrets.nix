{outputs, ...}: let
  agePath = ../secrets;
in {
  mkSecretFile = {
    user,
    source,
    destination ? null,
    owner ? null,
    group ? null,
    ...
  }:
  # Make sure to remove any null values or they will cause issues!
    outputs.lib.filterAttrs (n: v: v != null) {
      file = outputs.lib.path.append (agePath + "/${user}") source;
      path = destination;
      inherit owner;
      inherit group;
    };

  mkSecretIdentities = identity:
    outputs.lib.lists.forEach identity (x: outputs.lib.path.append (agePath + "/identities") x);

  evalSecret = user: builtins.fromJSON (builtins.readFile "${agePath}/${user}/eval-secrets.json");
}
