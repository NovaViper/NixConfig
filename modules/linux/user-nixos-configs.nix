args @ {
  outputs,
  users,
  config,
  ...
}: let
  userConfigs = builtins.map (username:
    outputs.lib.mkUser {
      inherit username;
      inherit (args) system hostname stateVersion;
      osConfig = config;
    })
  users;

  nixosConfigs = builtins.map (user: user.config.nixos) userConfigs;
in
  outputs.lib.deepMerge nixosConfigs
