# https://discourse.nixos.org/t/how-to-start-using-nix-os/37804/26
# https://github.com/Misterio77/nix-starter-configs/blob/972935c1b35d8b92476e26b0e63a044d191d49c3/standard/nixos/configuration.nix
{
  inputs,
  outputs,
  ...
}: rec {
  nix = {
    nixPath = ["/etc/nix/path"];
    registry = outputs.lib.mapAttrs (_: value: {flake = value;}) inputs;
  };

  environment.etc =
    outputs.lib.mapAttrs' (key: value: {
      name = "nix/path/${key}";
      value.source = value.flake;
    })
    nix.registry;
}
