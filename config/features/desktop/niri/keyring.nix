{
  config,
  lib,
  pkgs,
  ...
}:
let
  isFull = config.vars.desktop.profile == "full";
in
{
  services.gnome.gnome-keyring.enable = lib.mkForce false;
  xdg.portal.extraPortals = with pkgs; [ kdePackages.kwallet ];
  xdg.portal.config.common."org.freedesktop.impl.portal.Secret" = [ "kwallet" ];
  xdg.portal.config.niri."org.freedesktop.impl.portal.Secret" = lib.mkForce [ "kwallet" ];
  security.pam.services =
    let
      enableKeyrings = {
        # enableGnomeKeyring = true;
        kwallet.enable = true;
      };
    in
    {
      login = enableKeyrings // {
        # noctalia-v5 lockscreen fprint fix
        fprintAuth = !config.services.fprintd.enable;
      };
      greetd = enableKeyrings // {
        # force_run: TTY/logind sessions aren't detected as graphical, so
        # pam_kwallet would otherwise bail before reading PAM_AUTH_TOK
        kwallet.forceRun = true;
      };
      # noctalia-greeter = enableKeyrings;
    };

  environment.systemPackages = with pkgs; [
    libsecret
    kdePackages.kded
    kdePackages.kwallet
    kdePackages.kwalletmanager
    kdePackages.keepsecret
    # seahorse
  ];
  # ++ lib.optionals isFull [
  #   # seahorse
  # ];

  systemd.user.services.plasma-kwallet-pam =
    lib.mkIf (!config.services.desktopManager.plasma6.enable)
      {
        description = "Unlock KWallet from PAM credentials";

        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];

        serviceConfig = {
          Type = "simple";
          Slice = "background.slice";
          Restart = "no";

          ExecStart = pkgs.writeShellScript "kwallet-pam-unlock" ''
            set -eu

            for _ in $(seq 1 300); do
              wd="$(
                ${lib.getExe' pkgs.systemd "systemctl"} --user show-environment |
                  sed -n 's/^WAYLAND_DISPLAY=//p'
              )"

              if [ -n "$wd" ]; then
                export WAYLAND_DISPLAY="$wd"
                break
              fi

              sleep 0.1
            done

            if [ -z "''${WAYLAND_DISPLAY:-}" ]; then
              echo "WAYLAND_DISPLAY was not exported by the Niri session" >&2
              exit 1
            fi

            exec ${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init
          '';
        };
      };
  # systemd.user.services.polkit-authentication-agent = {
  #   description = "Polkit Authentication Agent";
  #   path = with pkgs; [
  #     kdePackages.polkit-kde-agent-1
  #   ];
  #   wantedBy = [ "graphical-session.target" ];
  #   wants = [ "graphical-session.target" ];
  #   after = [ "graphical-session.target" ];
  #   serviceConfig = {
  #     Type = "simple";
  #     ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
  #     Restart = "on-failure";
  #     RestartSec = 1;
  #   };
  # };

  # Lock secrets before suspend (carried over from KDE module)
  systemd.user.services.lock-secrets-on-suspend = {
    description = "Lock secrets before suspend";
    before = [ "sleep.target" ];
    wantedBy = [ "sleep.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "lock-secrets" ''
        # Lock KWallet/ksecretd
        ${pkgs.libsecret}/bin/secret-tool lock --collection=kdewallet 2>/dev/null || true

        # Lock rbw
        ${pkgs.rbw}/bin/rbw lock 2>/dev/null || true
      '';
    };
  };
}
