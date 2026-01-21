{
  config,
  myLib,
  lib,
  ...
}:
let
  repos = [
    {
      shortName = "abyneb";
      paths = [ "/mnt/sysbackup/PCBackups" ];
      pruneOpts = [
        "--keep-daily 5"
        "--keep-weekly 3"
        "--keep-monthly 6"
      ];
    }
  ];

  # Shared SOPS file for all repos
  sopsFile = myLib.secrets.mkSecretFile {
    source = "restic.yaml";
    subDir = [
      "hosts"
      "${config.networking.hostName}"
    ];
    restartUnits = map (repo: "restic-backups-${repo.shortName}") repos;
  };

  # Generate sops secrets dynamically
  sopsSecrets =
    lib.listToAttrs (
      lib.concatMap (repo: [
        {
          name = "repos/${repo.shortName}/b2-id";
          value = sopsFile;
        }
        {
          name = "repos/${repo.shortName}/b2-key";
          value = sopsFile;
        }
        {
          name = "repos/${repo.shortName}/bucket";
          value = sopsFile;
        }
      ]) repos
    )
    // {
      # Add the rest of the needed secrets
      "restic-pass" = myLib.secrets.mkSecretFile {
        source = "restic.yaml";
        subDir = [
          "hosts"
          "${config.networking.hostName}"
        ];
        restartUnits = map (repo: "restic-backups-${repo.shortName}") repos;
      };
    };

  # Generate sops templates dynamically
  resticTemplates = lib.listToAttrs (
    map (repo: {
      name = "restic-b2-${repo.shortName}-env";
      value = {
        content = ''
          B2_ACCOUNT_ID="${config.sops.placeholder."repos/${repo.shortName}/b2-id"}"
          B2_ACCOUNT_KEY="${config.sops.placeholder."repos/${repo.shortName}/b2-key"}"
        '';
      };
    }) repos
  );

  # Helper to configure restic with b2 options
  cfgB2 =
    {
      shortName,
      paths,
      pruneOpts ? [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
        "--keep-yearly 5"
      ],
    }:
    {
      inherit paths pruneOpts;
      initialize = true;
      timerConfig = {
        OnCalendar = "03:00";
        RandomizedDelaySec = "30min";
      };
      repositoryFile = config.sops.secrets."repos/${shortName}/bucket".path;
      environmentFile = config.sops.templates."restic-b2-${shortName}-env".path;
      passwordFile = config.sops.secrets."restic-pass".path;
    };
in
{
  # Inject secrets and templates
  sops.secrets = sopsSecrets;
  sops.templates = resticTemplates;

  # Define backups dynamically
  services.restic.backups = lib.listToAttrs (
    map (repo: {
      name = repo.shortName;
      value = cfgB2 {
        inherit (repo) paths pruneOpts shortName;
      };
    }) repos
  );

  systemd.services = (
    lib.listToAttrs (
      map (repo: {
        name = "restic-backups-${repo.shortName}";
        value.unitConfig = {
          OnSuccess = "notify-restic@success-${repo.shortName}.service";
          OnFailure = "notify-restic@failure-${repo.shortName}.service";
        };
      }) repos
    )
  );
}
