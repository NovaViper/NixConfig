# This file defines overlays
{ self, ... }:
let
  addPatches =
    pkg: patches:
    pkg.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ patches;
    });

  # Helper for referring to the new stdenv.hostPlatform.system, so we don't have
  # to write out that long string so many times
  refSystem = ref: ref.stdenv.hostPlatform.system;
in
{
  # Third party overlays
  nur = self.inputs.nur.overlays.default;
  sops-overlay = self.inputs.sops-nix.overlays.default;

  # For every flake input, aliases 'pkgs.inputs.${flake}' to
  # 'inputs.${flake}.packages.${pkgs.stdenv.hostPlatform.system}' or
  # 'inputs.${flake}.legacyPackages.${pkgs.stdenv.hostPlatform.system}'
  flake-inputs = final: _: {
    inputs = builtins.mapAttrs (
      _: flake:
      let
        legacyPackages = (flake.legacyPackages or { }).${refSystem final} or { };
        packages = (flake.packages or { }).${refSystem final} or { };
      in
      if legacyPackages != { } then legacyPackages else packages
    ) self.inputs;
  };

  # Adds pkgs.stable == inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system}
  stable = final: _: {
    stable = import self.inputs.nixpkgs-stable {
      localSystem = refSystem final;
      config.allowUnfree = true;
    };
  };

  # This one brings our custom packages from the 'pkgs' directory, use the new
  # fancy lib.packagesFromDirectoryRecursive to import our packages!
  # See: https://noogle.dev/f/lib/packagesFromDirectoryRecursive
  additions =
    final: prev:
    (prev.lib.packagesFromDirectoryRecursive {
      inherit (final) callPackage;
      directory = ../pkgs/common;
    })
    // (prev.lib.packagesFromDirectoryRecursive {
      callPackage = prev.lib.callPackageWith {
        inherit (final) lib;
        pkgs = prev;
        wrapPackage = self.inputs.wrappers.lib.wrapPackage;
      };
      directory = ../pkgs/wrappers;
    })
    // {

      /*
        formats =
        (prev.formats or {})
        // (prev.lib.packagesFromDirectoryRecursive {
          callPackage = prev.lib.callPackageWith final;
          directory = ../pkgs/formats;
        });
      */
      /*
        tmuxPlugins =
        (prev.tmuxPlugins or {})
        // (prev.lib.packagesFromDirectoryRecursive {
          inherit (final) callPackage;
          directory = ../pkgs/tmux-plugins;
        });
      */
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
            [ "for f in libGLESv2.so libqt5_shim.so ; do" ]
            [ "for f in libGLESv2.so libqt5_shim.so libqt6_shim.so ; do" ]
            oldAttrs.buildPhase;
      })).override
        {
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
      desktopItems = prev.lib.optionals final.stdenv.isLinux (
        prev.makeDesktopItem {
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
        }
      );
    };

    discord-wayland =
      let
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
