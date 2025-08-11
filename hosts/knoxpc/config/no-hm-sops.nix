{
  lib,
  ...
}:
{
  home-manager.sharedModules = lib.singleton { sops.secrets = lib.mkForce { }; };
}
