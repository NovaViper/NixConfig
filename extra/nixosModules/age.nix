{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.userVars;
in
  {imports = with inputs; [agenix.nixosModules.default];}
  // {
    options.userVars.userIdentityPaths = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.path);
      description = "List of secret identity paths for the user";
      default = null;
    };

    config = lib.mkMerge [
      (lib.mkIf (cfg.userIdentityPaths != null) {
        age.identityPaths = lib.mkOptionDefault cfg.userIdentityPaths;
        hm.age.identityPaths = lib.mkOptionDefault cfg.userIdentityPaths;
      })

      {
        home-manager.sharedModules = with inputs; lib.singleton agenix.homeManagerModules.default;

        environment.systemPackages = with pkgs; [agenix age age-plugin-yubikey];

        age.ageBin = "PATH=$PATH:${lib.makeBinPath [pkgs.age-plugin-yubikey]} ${lib.getExe pkgs.age}";

        services.pcscd.enable = lib.mkForce true;
      }
    ];
  }
