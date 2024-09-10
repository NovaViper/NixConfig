# This file defines overlays
{self, ...}: let
  addPatches = pkg: patches:
    pkg.overrideAttrs
    (oldAttrs: {patches = (oldAttrs.patches or []) ++ patches;});
in {
  # Third party overlays
  nur = self.inputs.nur.overlay;
  agenix-overlay = self.inputs.agenix.overlays.default;

  # For every flake input, aliases 'pkgs.inputs.${flake}' to
  # 'inputs.${flake}.packages.${pkgs.system}' or
  # 'inputs.${flake}.legacyPackages.${pkgs.system}'
  flake-inputs = final: _: {
    inputs = builtins.mapAttrs (_: flake: let
      legacyPackages = (flake.legacyPackages or {}).${final.system} or {};
      packages = (flake.packages or {}).${final.system} or {};
    in
      if legacyPackages != {}
      then legacyPackages
      else packages)
    self.inputs;
  };

  # Adds pkgs.stable == inputs.nixpkgs-stable.legacyPackages.${pkgs.system}
  stable = final: _: {
    stable = self.inputs.nixpkgs-stable.legacyPackages.${final.system};
  };

  # This one brings our custom packages from the 'pkgs' directory
  additions = final: prev:
    import ../pkgs {pkgs = final;}
    // {
      #formats = (prev.formats or {}) // import ../pkgs/formats {pkgs = final;};
      tmuxPlugins = (prev.tmuxPlugins or {}) // import ../pkgs/tmux-plugins {pkgs = final;};
    };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://wiki.nixos.org/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    # Enable DRM support in Vivaldi
    vivaldi = prev.vivaldi.override {
      proprietaryCodecs = true;
      enableWidevine = true;
    };

    # Fixes upstream bug borgbase/vorta/issues/2025
    vorta = addPatches prev.vorta [./vorta-extract.diff];
  };
}
