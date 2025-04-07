{
  config,
  lib,
  users,
  ...
}: let
  inherit (lib) mkIf mkOption types;
in {
  options.hmUser = mkOption {
    type = types.listOf types.raw;
    default = [];
    example =
      lib.literalExpression "[ { home.packages = [ nixpkgs-fmt ]; } ]";
    description = ''
      Extra modules added to home-manager.users.$\{users}
    '';
  };

  config = mkIf (config.hmUser != []) {
    home-manager.users = builtins.listToAttrs (
      map (u: {
        name = u;
        value = {imports = lib.flatten config.hmUser;};
      })
      users
    );
  };
}
