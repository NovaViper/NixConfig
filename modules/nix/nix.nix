{
  outputs,
  pkgs,
  system,
  hostname,
  ...
}:
outputs.lib.mkFor system hostname {
  common = {
    nix = {
      package = pkgs.nixVersions.nix_2_23;
      settings = import ./nix-config.nix;
    };
  };
}
