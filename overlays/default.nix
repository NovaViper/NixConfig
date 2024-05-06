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

    vivaldi = prev.vivaldi.override {
      proprietaryCodecs = true;
      enableWidevine = true;
    };

    papirus-icon-theme = prev.papirus-icon-theme.override {color = "violet";};

    tmux = prev.tmux.override {
      withSixel = true;
      withSystemd = true;
    };

    prismlauncher =
      prev.prismlauncher.override {withWaylandGLFW = true;};

    discord = prev.discord.override {
      withOpenASAR = true;
      withVencord = true;
    };

    btop = prev.btop.override {
      cudaSupport = true;
      rocmSupport = true;
    };
  };
}
