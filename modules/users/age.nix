{
  config,
  pkgs,
  outputs,
  ...
}:
with outputs.lib; let
  pcscdCfg = pkgs.writeText "reader.conf" "";
  pcscdPkg = pkgs.pcsclite;
  pcscdPluginEnv = pkgs.buildEnv {
    name = "pcscd-plugins";
    paths = map (p: "${p}/pcsc/drivers") [pkgs.ccid];
  };
in
  outputs.lib.mkModule' config "age" {
    userIdentityPaths = outputs.lib.mkOption {
      default = [];
      type = outputs.lib.types.listOf outputs.lib.types.path;
      description = "List of secret identity paths for the user";
    };
  } {
    age.identityPaths = outputs.lib.mkIf (config.userIdentityPaths != []) (outputs.lib.mkOptionDefault config.userIdentityPaths);

    nixos = {
      environment.systemPackages = with pkgs; [agenix age age-plugin-yubikey];

      age = {
        ageBin = "PATH=$PATH:${makeBinPath [pkgs.age-plugin-yubikey]} ${pkgs.age}/bin/age";
        identityPaths = outputs.lib.mkIf (config.userIdentityPaths != []) (outputs.lib.mkOptionDefault config.userIdentityPaths);
      };

      services.pcscd.enable = mkForce true;
      #systemd.services.pcscd.serviceConfig.ExecStart = mkForce [
      #   "${pcscdPkg}/bin/pcscd -f -c ${pcscdCfg}"
      #];

      # HACK: Start pcscd before decrypting secrets
      boot.initrd.systemd = {
        enable = mkDefault true;
        packages = [(getBin pcscdPkg)];
        storePaths = [
          "${pcscdPkg}/bin/pcscd"
          "${pcscdCfg}"
          "${pcscdPluginEnv}"
        ];

        sockets.pcscd.wantedBy = ["sockets.target"];
        services.pcscd = {
          environment.PCSCLITE_HP_DROPDIR = pcscdPluginEnv;
          after = ["rollback.service"];
          serviceConfig.ExecStart = [
            ""
            "${pcscdPkg}/bin/pcscd -f -c ${pcscdCfg}"
          ];
        };
      };
    };
  }
