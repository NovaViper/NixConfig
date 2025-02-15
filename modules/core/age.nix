{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.variables;
  pcscdCfg = pkgs.writeText "reader.conf" "";
  pcscdPkg = pkgs.pcsclite;
  pcscdPluginEnv = pkgs.buildEnv {
    name = "pcscd-plugins";
    paths = map (p: "${p}/pcsc/drivers") [pkgs.ccid];
  };
in
  {imports = with inputs; [agenix.nixosModules.default];}
  // {
    options.variables.userIdentityPaths = lib.mkOption {
      default = [];
      type = lib.types.listOf lib.types.path;
      description = "List of secret identity paths for the user";
    };

    config = lib.mkMerge [
      (lib.mkIf (cfg.userIdentityPaths != []) {
        age.identityPaths = lib.mkOptionDefault cfg.userIdentityPaths;
        hm.age.identityPaths = lib.mkOptionDefault cfg.userIdentityPaths;
      })

      {
        home-manager.sharedModules = with inputs; lib.singleton agenix.homeManagerModules.default;

        environment.systemPackages = with pkgs; [agenix age age-plugin-yubikey];

        age.ageBin = "PATH=$PATH:${lib.makeBinPath [pkgs.age-plugin-yubikey]} ${lib.getExe pkgs.age}";

        services.pcscd.enable = lib.mkForce true;
        # TODO: Figure out why this is broken
        systemd.services.pcscd.serviceConfig.ExecStart = lib.mkForce [
          ""
          "${lib.getExe' pcscdPkg "pcscd"} -f -x -c ${pcscdCfg}"
        ];

        # HACK: Start pcscd before decrypting secrets
        boot.initrd.systemd = {
          enable = lib.mkDefault true;
          packages = [(lib.getBin pcscdPkg)];
          storePaths = [
            "${lib.getExe' pcscdPkg "pcscd"}"
            "${pcscdCfg}"
            "${pcscdPluginEnv}"
          ];

          sockets.pcscd.wantedBy = ["sockets.target"];
          services.pcscd = {
            environment.PCSCLITE_HP_DROPDIR = pcscdPluginEnv;
            after = ["rollback.service"];
            serviceConfig.ExecStart = [
              ""
              "${lib.getExe' pcscdPkg "pcscd"} -f -x -c ${pcscdCfg}"
            ];
          };
        };
      }
    ];
  }
