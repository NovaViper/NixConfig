{outputs, ...}: {
  options = {
    nixos = outputs.lib.mkOption {
      type = outputs.lib.types.attrs;
      default = {};
      description = ''
        Adds support to define additional NixOS system configurations.
        Without this module, home-manager will complain about the "nixos" option not existing.
      '';
    };
    macos = outputs.lib.mkOption {
      type = outputs.lib.types.attrs;
      default = {};
      description = ''
        Adds support to define additional Nix-Darwin system configurations.
        Without this module, home-manager will complain about the "macos" option not existing.
      '';
    };
  };
}
