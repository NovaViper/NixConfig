{
  config,
  lib,
  myLib,
  pkgs,
  inputs,
  ...
}:
let

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
  programs.msmtp =
    let
      fromAddress = inputs.nix-secrets.email.knoxpc.msmtp;
    in
    {
      enable = true;
      accounts.default = {
        host = "smtp.protonmail.ch";
        port = 587;
        auth = true;
        tls = true;
        tls_starttls = true;
        user = "${fromAddress}";
        from = "${fromAddress}";
        passwordeval = "cat ${config.sops.secrets."msmtp-pass".path}";
      };
    };

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
                MAILTO="${config.vars.user.email}"

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
