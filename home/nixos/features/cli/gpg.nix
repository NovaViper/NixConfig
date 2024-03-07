{ inputs, config, pkgs, ... }:
let
  desktop = config.variables.desktop.environment;

  pinentry = if (desktop == "kde") then {
    name = "qt";
  } else if (desktop == "xfce") then {
    name = "gtk";
    #packages = [ pkgs.pinentry-gnome pkgs.gcr ];
  } else {
    #packages = [ pkgs.pinentry-curses ];
    name = "curses";
  };

in {

  # Make gpg use pinentry
  services.gpg-agent = {
    enable = true;
    #enableSshSupport = true;
    pinentryFlavor = pinentry.name;
    # HACK Without this config file you get "No pinentry program" on 23.05. programs.gnupg.agent.pinentryFlavor doesn't appear to work, and this
    extraConfig = ''
      allow-loopback-pinentry
    '';
  };

  programs.gpg = {
    enable = true;
    settings = { trust-model = "tofu+pgp"; };
    # Make Yubikeys work
    scdaemonSettings = {
      reader-port = "Yubico Yubi";
      disable-ccid = true;
    };
  };
}
