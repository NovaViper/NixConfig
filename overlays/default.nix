# This file defines overlays
{
  outputs,
  inputs,
  ...
}: let
  addPatches = pkg: patches:
    pkg.overrideAttrs
    (oldAttrs: {patches = (oldAttrs.patches or []) ++ patches;});
in {
  # Third party overlays
  nur = inputs.nur.overlay;

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
    inputs;
  };

  # Adds pkgs.stable == inputs.nixpkgs-stable.legacyPackages.${pkgs.system}
  stable = final: _: {
    stable = inputs.nixpkgs-stable.legacyPackages.${final.system};
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
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    # Enable DRM support in Vivaldi
    vivaldi = prev.vivaldi.override {
      proprietaryCodecs = true;
      enableWidevine = true;
    };

    # TODO: Remove when https://github.com/NixOS/nixpkgs/pull/310073 is merged
    prismlauncher =
      prev.prismlauncher.override {withWaylandGLFW = true;};

    # Make btop compile with GPU support (Nvidia and AMD)
    btop = prev.btop.override {
      cudaSupport = true;
      rocmSupport = true;
    };

    # For Nvidia GPUs
    sunshine = prev.sunshine.override {cudaSupport = true;};
  };
}
