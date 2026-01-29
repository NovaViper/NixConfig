{
  config,
  myLib,
  lib,
  ...
}:
let
  # MAIN REPO DECLARATION
  repos = {
    abyneb = {
      paths = [ "/mnt/sysbackup/PCBackups" ];
      pruneOpts = [
        "--keep-daily 5"
        "--keep-weekly 3"
        "--keep-monthly 6"
      ];
    };
    sinecl = {
      paths = [
        "/mnt/media/Library"
      ]
      ++ lib.optionals config.services.immich.enable [
        config.services.immich.mediaLocation
        "/var/lib/pgdump"
      ]
      # TODO: Better way to back this up without backing up the synced files
      # ++ lib.optionals config.services.syncthing.enable [
      #   config.services.syncthing.dataDir
      # ]
      ;
      preBackupScripts = lib.optionals (config.services.immich.enable) [
        "systemctl start pgDumpImmich"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
        "--keep-yearly 5"
      ];
    };
  };

  repoNames = builtins.attrNames repos;
  resticUnitName = name: "restic-backups-${name}";
  resticEnvTemplate = name: "restic-b2-${name}-env";
  restartUnits = map (name: "${resticUnitName name}.service") repoNames;

  # Shared SOPS file for all repos
  sopsFile = myLib.secrets.mkSecretFile {
    source = "restic.yaml";
    subDir = [
      "hosts"
      config.networking.hostName
    ];
    inherit restartUnits;
  };

  # Generate sops secrets dynamically
  sopsSecrets = lib.genAttrs (
    [ "restic-pass" ]
    ++ lib.concatMap (name: [
      "repos/${name}/b2-id"
      "repos/${name}/b2-key"
      "repos/${name}/bucket"
    ]) repoNames
  ) (_: sopsFile);

  # Generate sops templates dynamically
  resticTemplates = lib.listToAttrs (
    map (name: {
      name = resticEnvTemplate name;
      value.content = ''
        B2_ACCOUNT_ID="${config.sops.placeholder."repos/${name}/b2-id"}"
        B2_ACCOUNT_KEY="${config.sops.placeholder."repos/${name}/b2-key"}"
      '';
    }) repoNames
  );

  # Helper to configure restic with b2 options
  cfgB2 =
    name: repoCfg:
    let
      paths = repoCfg.paths or null;
      pruneOpts = repoCfg.pruneOpts or null;
      extraBackupArgs = repoCfg.extraBackupArgs or null;
      extraOptions = repoCfg.extraOptions or null;
      preCmds = repoCfg.preBackupScripts or null;
      postCmds = repoCfg.postBackupScripts or null;
    in
    lib.filterAttrs (_: v: v != null) {
      inherit
        paths
        pruneOpts
        extraBackupArgs
        extraOptions
        ;
      initialize = true;
      timerConfig = {
        OnCalendar = "03:00";
        Persistent = true;
        RandomizedDelaySec = "30min";
      };
      repositoryFile = config.sops.secrets."repos/${name}/bucket".path;
      environmentFile = config.sops.templates."${resticEnvTemplate name}".path;
      passwordFile = config.sops.secrets."restic-pass".path;

      # Join pre/post backup scripts lists into singular module options
      backupPrepareCommand = if preCmds != null then builtins.concatStringsSep "\n" preCmds else null;
      backupCleanupCommand = if postCmds != null then builtins.concatStringsSep "\n" postCmds else null;
    };

  backupServiceNotifications = map (name: {
    name = resticUnitName name;
    value.unitConfig = {
      OnSuccess = "notify-restic@success-${name}.service";
      OnFailure = "notify-restic@failure-${name}.service";
    };
  }) repoNames;
in
{
  # Inject secrets and templates
  sops.secrets = sopsSecrets;
  sops.templates = resticTemplates;

  # Define backups dynamically
  services.restic.backups = lib.genAttrs repoNames (n: cfgB2 n repos.${n});

  # Bind email notifications (defined in ./smtp.nix)
  systemd.services = lib.listToAttrs backupServiceNotifications;
}
