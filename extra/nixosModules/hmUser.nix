{
  config,
  lib,
  allUsers,
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
    home-manager.users = builtins.listToAttrs (map (u: lib.nameValuePair u {imports = lib.flatten config.hmUser;}) allUsers);
  };
}
