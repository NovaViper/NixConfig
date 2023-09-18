{ inputs, config, pkgs, ... }: {

  programs.gpg = {
    enable = true;
    scdaemonSettings = {
      reader-port = "Yubico Yubi";
      disable-ccid = true;
    };
  };

  # Make gpg use pinentry
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableZshIntegration = true;
    pinentryFlavor = "qt";
    # HACK Without this config file you get "No pinentry program" on 23.05. programs.gnupg.agent.pinentryFlavor doesn't appear to work, and this
    extraConfig = ''
      allow-emacs-pinentry
      allow-loopback-pinentry
    '';
  };
}
