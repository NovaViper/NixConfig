{ inputs, config, pkgs, ... }:
let
  desktop = config.variables.desktop.environment;

  pinentry = if (desktop == "kde") then {
    pkg = pkgs.pinentry-qt;
  } else if (desktop == "xfce") then {
    pkg = pkgs.pinentry-gnome;
  } else {
    pkg = pkgs.pinentry-curses;
  };

in {

  # Make gpg use pinentry
  services.gpg-agent = {
    enable = true;
    #enableSshSupport = true;
    # HACK Without this config file you get "No pinentry program" on 23.05. programs.gnupg.agent.pinentryFlavor doesn't appear to work, and this
    #pinentryPackage = pinentry.pkg;
    extraConfig = ''
      allow-loopback-pinentry
    '';
  };

  programs.gpg = {
    enable = true;
    settings = {
      trust-model = "tofu+pgp";
      default-recipient-self = true;
    };
    # Make Yubikeys work
    scdaemonSettings = {
      reader-port = "Yubico Yubi";
      disable-ccid = true;
    };
  };
}
