{
  lib,
  ...
}:
{
  hm.sops.secrets = lib.mkForce { };
}
