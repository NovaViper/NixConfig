# Llakala's fancy rebuild packages
{
  config,
  myLib,
  pkgs,
  ...
}: let
  hm-config = config.hm;
in {
  environment.sessionVariables = {
    RBLD_DIRECTORY = myLib.flakePath hm-config;
    UNIFY_DIRECTORY = myLib.flakePath hm-config;

    UNIFY_TRACKED_INPUTS = "nixpkgs nixpkgs-stable home-manager rebuild-but-less-dumb";
    UNIFY_COMMIT_MESSAGE = "chore: update flake.lock";
    UNIFY_PRIMARY_BRANCHES = "main master";
  };

  environment.systemPackages = with pkgs; [
    inputs.rebuild-but-less-dumb.rbld
    inputs.rebuild-but-less-dumb.unify
  ];
}
