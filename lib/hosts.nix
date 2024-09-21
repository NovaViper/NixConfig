flake @ {
  inputs,
  outputs,
  ...
}: let
  sharedModules = [
    ../modules/nix/nix.nix
    ../modules/nix/nixpkgs.nix
    ../modules/nix/legacy-consistency.nix
    ../modules/home-manager/submodule.nix
  ];
in rec {
  mkHost = args @ {
    hostname,
    system,
    users ? [],
    stateVersion ? outputs.lib.defaultStateVersionForSystem system,
    ...
  }: let
    args' =
      args
      // {
        # https://nixos.wiki/wiki/Nix_Language_Quirks#Default_values_are_not_bound_in_.40_syntax
        inherit users stateVersion;
      };
  in
    if outputs.lib.isLinux system
    then mkNixos args'
    #else if outputs.lib.isDarwin system then
    #  mkDarwin args'
    else throw "Unsupported system: ${system}";

  mkNixos = args @ {
    hostname,
    system,
    stateVersion,
    users,
  }:
    outputs.lib.nixosSystem {
      inherit system;
      specialArgs = flake // args;

      modules =
        sharedModules
        ++ [
          ../hosts/${hostname}/configuration.nix
          ../hosts/${hostname}/hardware-configuration.nix
          ../modules/linux/default-config.nix
          inputs.stylix.nixosModules.stylix
          inputs.nur.nixosModules.nur
          inputs.agenix.nixosModules.default
        ];
    };

  /*
  mkDarwin = args@{ hostname, system, stateVersion, users }:
  outputs.lib.darwinSystem {
    inherit system;
    specialArgs = flake // args;

    modules = sharedModules ++ [
      ../hosts/${hostname}/configuration.nix
      ../modules/darwin/default-config.nix
    ];
  };
  */
}
