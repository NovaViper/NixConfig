{
  inputs,
  config,
  pkgs,
  ...
}: let
  desktop = config.variables.desktop.environment;

  pinentry =
    if (desktop == "kde")
    then {
      pkg = pkgs.pinentry-qt;
    }
    else if (desktop == "xfce")
    then {
      pkg = pkgs.pinentry-gnome;
    }
    else {
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
      allow-emacs-pinentry
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

  home.shellAliases = {
    # Make gpg switch Yubikey
    gpg-switch-yubikey = ''gpg-connect-agent "scd serialno" "learn --force" /bye'';

    # Make gpg smartcard functionality work again
    #fix-gpg-smartcard =
    #"pkill gpg-agent && sudo systemctl restart pcscd.service && sudo systemctl restart pcscd.socket && gpg-connect-agent /bye";
    # Load PKCS11 keys into ssh-agent
    load-pkcs-key = "ssh-add -s ${pkgs.opensc}/lib/pkcs11/opensc-pkcs11.so";
    # Remove PKCS11 keys into ssh-agent
    remove-pkcs-key = "ssh-add -e ${pkgs.opensc}/lib/pkcs11/opensc-pkcs11.so";
    # Remove all identities
    remove-ssh-keys = "ssh-add -D";
    # List all SSH keys in the agent
    list-ssh-key = "ssh-add -L";
    # Make resident ssh keys import from Yubikey
    load-res-keys = "ssh-keygen -K";
    # Quickly start Minecraft server
  };

  /*
  systemd.user.services = {
    # Link /run/user/$UID/gnupg to ~/.gnupg-sockets
    # So that SSH config does not have to know the UID
    link-gnupg-sockets = {
      Unit = { Description = "link gnupg sockets from /run to /home"; };
      Service = {
        Type = "oneshot";
        ExecStart =
          "${pkgs.coreutils}/bin/ln -Tfs /run/user/%U/gnupg %h/.gnupg-sockets";
        ExecStop = "${pkgs.coreutils}/bin/rm $HOME/.gnupg-sockets";
        RemainAfterExit = true;
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
  */
}
