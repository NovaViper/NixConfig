{
  config,
  lib,
  myLib,
  pkgs,
  options,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types mkMerge;
  cfg = config.userVars;
  cfgFeat = config.features;

  userOptions = {config, ...}: {
    options = {
      username = mkOption {
        type = types.str;
        description = "The name of the current user";
        default = "";
      };
      fullName = mkOption {
        type = types.str;
        description = "Your first and last name";
        default = "";
      };
      email = mkOption {
        type = types.str;
        description = "Your email address";
        default = "";
      };
      homeDirectory = mkOption {
        type = types.str;
        description = ''
          The directory for the user's folders. This should only be set if it's in a non-default location.
        '';
        default = "/home/${config.username}";
      };
      defaultTerminal = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      defaultBrowser = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      defaultEditor = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      userIdentityPaths = mkOption {
        type = types.nullOr (types.listOf types.path);
        description = "List of secret identity paths for the user";
        default = null;
      };
    };
  };
in
  {imports = lib.singleton inputs.agenix.nixosModules.default;}
  // {
    options.userVars = mkOption {
      type = types.attrsOf (types.submodule userOptions);
      default = {};
      example = {
        nixos = {
          fullName = "test";
          email = "test@example.com";
          defaultTerminal = "ghostty";
          defaultBrowser = "vivaldi";
          defaultEditor = "nvim";
        };
      };
    };

    /*
      config.assertions = [
      {
        assertion = (cfg.defaultTerminal != null) -> (cfgFeat.desktop != "none");
        message = "variables.defaultTerminal must be defined when modules.desktop is enabled!";
      }
      {
        assertion = (cfg.defaultBrowser != null) -> (cfgFeat.desktop != "none");
        message = "variables.defaultBrowser must be defined when modules.desktop is enabled!";
      }
    ];
    */

    config = let
      cfgVars = opt: builtins.catAttrs opt (builtins.attrValues cfg);
    in
      mkMerge [
        # Age setup
        {
          home-manager.sharedModules = lib.singleton inputs.agenix.homeManagerModules.default;

          environment.systemPackages = with pkgs; [agenix age age-plugin-yubikey];

          age.ageBin = "PATH=$PATH:${lib.makeBinPath [pkgs.age-plugin-yubikey]} ${lib.getExe pkgs.age}";

          services.pcscd.enable = lib.mkForce true;
        }

        # Age variable declaration
        (lib.mkIf (cfgVars "userIdentityPaths" != null) {
          age.identityPaths = lib.mkOptionDefault (myLib.utils.getUserVars "userIdentityPaths" config);

          hmUser = lib.singleton {
            age.identityPaths = lib.mkOptionDefault (myLib.utils.getUserVars "userIdentityPaths" config);
          };
        })

        (mkIf (config.userVars != {}) {
          assertions = [
            {
              assertion = (cfgVars "defaultTerminal" != null) -> (cfgFeat.desktop != null);
              message = "variables.defaultTerminal must be defined when modules.desktop is enabled!";
            }
            {
              assertion = (cfgVars "defaultBrowser" != null) -> (cfgFeat.desktop != null);
              message = "variables.defaultBrowser must be defined when modules.desktop is enabled!";
            }
          ];
        })
      ];
  }
