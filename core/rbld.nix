# Llakala's fancy rebuild packages
{
  config,
  myLib,
  pkgs,
  ...
}: {
  environment.sessionVariables = {
    RBLD_DIRECTORY = config.hostVars.configDirectory;
    UNIFY_DIRECTORY = config.hostVars.configDirectory;

    UNIFY_TRACKED_INPUTS = "nixpkgs nixpkgs-stable home-manager menu";
    UNIFY_COMMIT_MESSAGE = "chore: update flake.lock";
    UNIFY_PRIMARY_BRANCHES = "main master";
  };

  environment.systemPackages = with pkgs.inputs.menu; [
    rbld
    unify
    fuiska
  ];
}
