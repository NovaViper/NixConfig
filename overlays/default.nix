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
    stable = import self.inputs.nixpkgs-stable {
      inherit (final) system;
      config.allowUnfree = true;
    };
    #stable = self.inputs.nixpkgs-stable.legacyPackages.${final.system};
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
    # example = prev.example.overrideAttrs (oldAttrs: {
    # ...
    # });

    # Enable DRM support in Vivaldi and make it work properly on Wayland
    vivaldi =
      (prev.vivaldi.overrideAttrs (oldAttrs: {
        buildPhase =
          builtins.replaceStrings
          ["for f in libGLESv2.so libqt5_shim.so ; do"]
          ["for f in libGLESv2.so libqt5_shim.so libqt6_shim.so ; do"]
          oldAttrs.buildPhase;
      }))
      .override {
        qt5 = prev.qt6;
        commandLineArgs = [
          "--ozone-platform=wayland"
          "--force-dark-mode"
          "--enable-force-dark"
        ];
        # The following two are just my preference, feel free to leave them out
        proprietaryCodecs = true;
        enableWidevine = true;
      };

    vesktop = prev.vesktop.overrideAttrs {
      desktopItems = prev.lib.optionals final.stdenv.isLinux (prev.makeDesktopItem {
        name = "vesktop";
        desktopName = "Vesktop";
        exec = "vesktop --disable-features=UseMultiPlaneFormatForSoftwareVideo %U";
        icon = "vesktop";
        startupWMClass = "Vesktop";
        genericName = "Internet Messenger";
        keywords = [
          "discord"
          "vencord"
          "electron"
          "chat"
        ];
        categories = [
          "Network"
          "InstantMessaging"
          "Chat"
        ];
      });
    };

    discord-wayland = let
      discord = prev.discord.override {
        withOpenASAR = true;
        withVencord = true;
      };
    in
      prev.symlinkJoin {
        name = "Discord";
        paths = [
          (prev.writeShellScriptBin "Discord" ''
            exec ${discord}/bin/Discord \
              --enable-features=UseOzonePlatform,WaylandWindowDecorations \
              --ozone-platform-hint=auto \
              --ozone-platform=wayland \
              "$@"
          '')
          discord
        ];
      };
  };
}
