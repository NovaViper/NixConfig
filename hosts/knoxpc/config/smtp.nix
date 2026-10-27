{
  config,
  lib,
  myLib,
  pkgs,
  inputs,
  ...
}:
let
  labAddress = inputs.nix-secrets.email.knoxpc.msmtp;
  myAddress = config.vars.user.email;
in
{

  sops.secrets."msmtp-pass" = myLib.secrets.mkSecretFile {
    source = "secrets.yaml";
    subDir = [
      "hosts"
      "${config.networking.hostName}"
    ];
  };

  # Email service
  programs.msmtp = {
    enable = true;
    accounts.default = {
      host = "smtp.protonmail.ch";
      port = 587;
      auth = true;
      tls = true;
      tls_starttls = true;
      user = "${labAddress}";
      from = "${labAddress}";
      passwordeval = "cat ${config.sops.secrets."msmtp-pass".path}";
    };
  };

  # ZFS events use the system sendmail provided by msmtp above.
  services.zfs.zed = {
    enableMail = true;
    settings = {
      ZED_EMAIL_ADDR = [ myAddress ];
      # Include successful scrub/resilver reports, not just failures.
      ZED_NOTIFY_VERBOSE = true;
      # Limit repeated notifications for the same event to once per hour.
      ZED_NOTIFY_INTERVAL_SECS = 3600;
    };
  };

  # Restic backup results use the same mail transport.
  systemd.services."notify-restic@" = {
    restartIfChanged = false;
    serviceConfig = {
      Type = "oneshot";
      ExecStart =
        pkgs.writeShellScript "notify-restic.sh" ''
                INSTANCE="$1"
                STATUS="''${INSTANCE%%-*}"
                REPO="''${INSTANCE#*-}"

                HOST="${config.networking.hostName}"
                UNIT="restic-backups-$REPO"
                LOGS="$(${pkgs.systemd}/bin/journalctl -u "$UNIT" -n 50 --no-pager || true)"
                MAILTO="${myAddress}"

                ${pkgs.system-sendmail}/bin/sendmail -t << EOF
          To: $MAILTO
          Subject: [$HOST] Restic backup $STATUS: $UNIT

          Host: $HOST
          Service: $UNIT
          Result: $STATUS

          Last 50 log lines:

          $LOGS
          EOF
        ''
        + " %i";
    };
  };
}
