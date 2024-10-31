# Llakala's fancy rebuild packages
{pkgs, ...}: {
  environment.sessionVariables.INPUTS_TRIGGERING_REBUILD = "nixpkgs nixpkgs-stable home-manager rebuild-but-less-dumb";

  environment.systemPackages = with pkgs; [
    inputs.rebuild-but-less-dumb.rbld
    inputs.rebuild-but-less-dumb.unify
  ];
}
