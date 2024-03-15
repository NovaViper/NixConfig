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

  /* systemd.user.services = {
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
