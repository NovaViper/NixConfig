flake @ {
  inputs,
  outputs,
  ...
}: {
  mkUser = args @ {
    username,
    hostname ? null,
    system ? outputs.lib.defaultSystem,
    stateVersion ? outputs.lib.defaultStateVersion,
    osConfig ? null,
    ...
  }:
    outputs.lib.homeManagerConfiguration {
      pkgs = outputs.lib.pkgsFor.${system};

      extraSpecialArgs =
        flake
        // args
        // {
          # https://nixos.wiki/wiki/Nix_Language_Quirks#Default_values_are_not_bound_in_.40_syntax
          inherit system hostname stateVersion osConfig;

          # Actual name required by submodules. This makes sure everything is
          # interopable across NixOS & non-NixOS systems.
          # https://github.com/nix-community/home-manager/blob/ca4126e3c568be23a0981c4d69aed078486c5fce/nixos/common.nix#L22
          name = username;
        };

      modules = with inputs; [
        ../modules/home-manager/shared.nix
        ../modules/home-manager/default-config.nix
        ../modules/nix/nix.nix

        nur.hmModules.nur
        stylix.homeManagerModules.stylix

        ../users/${username}
      ];
    };
}
