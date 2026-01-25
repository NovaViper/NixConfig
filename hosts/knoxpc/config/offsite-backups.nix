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
  };

  repoNames = builtins.attrNames repos;
  restic = {
    unitName = name: "restic-backups-${name}";
    envTemplate = name: "restic-b2-${name}-env";
  };
  restartUnits = map restic.unitName repoNames;

  # Shared SOPS file for all repos
  sopsFile = myLib.secrets.mkSecretFile {
    source = "restic.yaml";
    subDir = [
      "hosts"
      "${config.networking.hostName}"
    ];
    inherit restartUnits;
  };

  # Generate sops secrets dynamically
  sopsSecrets =
    lib.listToAttrs (
      lib.concatMap (name: [
        {
          name = "repos/${name}/b2-id";
          value = sopsFile;
        }
        {
          name = "repos/${name}/b2-key";
          value = sopsFile;
        }
        {
          name = "repos/${name}/bucket";
          value = sopsFile;
        }
      ]) repoNames
    )
    // {
      # Add the rest of the needed secrets
      "restic-pass" = sopsFile;
    };

  # Generate sops templates dynamically
  resticTemplates = lib.mapAttrs' (name: _: {
    name = restic.envTemplate name;
    value.content = ''
      B2_ACCOUNT_ID="${config.sops.placeholder."repos/${name}/b2-id"}"
      B2_ACCOUNT_KEY="${config.sops.placeholder."repos/${name}/b2-key"}"
    '';
  }) repos;

  # Helper to configure restic with b2 options
  cfgB2 =
    name:
    {
      paths,
      pruneOpts ? [ ],
    }:
    {
      inherit paths pruneOpts;
      initialize = true;
      timerConfig = {
        OnCalendar = "03:00";
        Persistent = true;
        RandomizedDelaySec = "30min";
      };
      repositoryFile = config.sops.secrets."repos/${name}/bucket".path;
      environmentFile = config.sops.templates."restic-b2-${name}-env".path;
      passwordFile = config.sops.secrets."restic-pass".path;
    };
in
{
  # Inject secrets and templates
  sops.secrets = sopsSecrets;
  sops.templates = resticTemplates;

  # Define backups dynamically
  services.restic.backups = lib.mapAttrs (name: repoCfg: cfgB2 name repoCfg) repos;

  # Bind email notifications (defined in ./smtp.nix)
  systemd.services = lib.listToAttrs (
    map (name: {
      name = restic.unitName name;
      value.unitConfig = {
        OnSuccess = "notify-restic@success-${name}.service";
        OnFailure = "notify-restic@failure-${name}.service";
      };
    }) repoNames
  );
}
