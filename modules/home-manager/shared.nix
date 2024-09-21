# Modules shared across NixOS, Darwin, and standalone Home Configurations
{
  inputs,
  outputs,
  system,
  hostname,
  ...
}:
outputs.lib.mkFor system hostname {
  common = {
    imports = with inputs; [
      agenix.homeManagerModules.default
      nix-index-database.hmModules.nix-index
      ../nix/nixpkgs.nix
      ./system-config-support.nix
    ];
    options.isDesktop = outputs.lib.mkEnableOption "Override isDesktop";
  };

  systems.linux.imports = with inputs; [
    plasma-manager.homeManagerModules.plasma-manager
  ];

  /*
    systems.darwin.imports = with inputs; [
    mac-app-util.homeManagerModules.default
  ];
  */
}
