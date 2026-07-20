{
  config,
  lib,
  pkgs,
  ...
}:
let
  hm-config = config.hm;
  bridgeCert = "${hm-config.xdg.configHome}/protonmail/cert.pem";
  bridgeGluonDb = "${hm-config.xdg.dataHome}/protonmail/bridge-v3/gluon/backend/db";
in
{
  hm.services.protonmail-bridge = {
    enable = true;
    extraPackages = with pkgs; [
      kdePackages.kwallet
      libsecret
    ];
    logLevel = "info";
  };

  hm.home.packages = with pkgs; [ protonmail-export ];

  # Shamelessly stolen from
  # https://github.com/dailyherold/nixfiles/blob/6e9dc6ed10858b9dc74c25ad6824ae654852ac2c/home-manager/features/cli/protonmail-bridge.nix
  hm.home.activation.checkBridgeLogin = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -z "$(ls -A "${bridgeGluonDb}" 2>/dev/null)" ]; then
      echo ""
      echo "WARNING: Proton Bridge not logged in (gluon db empty at ${bridgeGluonDb})"
      echo "Run the following to log in and retrieve the local IMAP/SMTP password:"
      ${''
        echo "  systemctl --user stop protonmail-bridge"
        echo "  protonmail-bridge --cli"
        echo "  > login"
        echo "  > list        # find your account index"
        echo "  > info 0      # shows IMAP/SMTP password"
        echo "  > exit"
        echo "  systemctl --user start protonmail-bridge"
        echo "Then store the password:"
        echo "  NixOS: sops ~/dev/nix-secrets/secrets/nixzen.yaml → fill in proton-bridge/password"
      ''}
      echo ""
    fi
  '';

  hm.home.activation.checkBridgeCert = lib.hm.dag.entryAfter [ "checkBridgeLogin" ] ''
    if [ ! -f "${bridgeCert}" ]; then
      echo ""
      echo "WARNING: Proton Bridge cert missing at ${bridgeCert}"
      echo "IMAP will fail until you run (once per machine):"
      ${''
        echo "  systemctl --user stop protonmail-bridge"
        echo "  protonmail-bridge --cli"
        echo "  > cert export"
        echo "  > (enter path when prompted: ${dirOf bridgeCert})"
        echo "  > exit"
        echo "  systemctl --user start protonmail-bridge"
      ''}
      echo ""
    fi
  '';
}
