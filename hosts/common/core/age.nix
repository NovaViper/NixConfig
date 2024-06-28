{
  config,
  lib,
  pkgs,
  inputs,
  options,
  ...
}: let
  agePath = path: ../../../secrets/${path};

  pcscdCfg = pkgs.writeText "reader.conf" "";
  pcscdPkg = pkgs.pcsclite;
  pcscdPluginEnv = pkgs.buildEnv {
    name = "pcscd-plugins";
    paths = map (p: "${p}/pcsc/drivers") [pkgs.ccid];
  };
in {
  imports = with inputs; [agenix.nixosModules.default];

  environment.systemPackages = with pkgs; [agenix age age-plugin-yubikey];

  age = {
    ageBin = "PATH=$PATH:${lib.makeBinPath [pkgs.age-plugin-yubikey]} ${pkgs.age}/bin/age";
    identityPaths =
      [
        (agePath "identities/age-yubikey-identity-a38cb00a-usba.txt")
        #(agePath "identities/age-yubikey-identity-ID-INTERFACE.txt")
      ]
      ++ options.age.identityPaths.default;
  };

  services.pcscd.enable = lib.mkForce true;
  systemd.services.pcscd.serviceConfig.ExecStart = lib.mkForce [
    ""
    "${pcscdPkg}/bin/pcscd -f -c ${pcscdCfg}"
  ];

  # HACK: Start pcscd before decrypting secrets
  boot.initrd.systemd = {
    enable = lib.mkDefault true;
    packages = [(lib.getBin pcscdPkg)];
    storePaths = [
      "${pcscdPkg}/bin/pcscd"
      "${pcscdCfg}"
      "${pcscdPluginEnv}"
    ];

    sockets.pcscd.wantedBy = ["sockets.target"];
    services.pcscd = {
      environment.PCSCLITE_HP_DROPDIR = pcscdPluginEnv;
      after = [
        "rollback.service"
      ];
      serviceConfig.ExecStart = [
        ""
        "${pcscdPkg}/bin/pcscd -f -c ${pcscdCfg}"
      ];
    };
  };
}
