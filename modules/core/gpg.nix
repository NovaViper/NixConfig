{pkgs, ...}: {
  # Make gnupg agent run with ssh support
  programs.gnupg.agent = {
    enable = true;
    #enableSSHSupport = true;
  };

  environment = {
    systemPackages = with pkgs; [gnupg];

    /*
    shellInit = ''
      gpg-connect-agent /bye
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    '';
    */
  };

  hm = {
    # Make gpg use pinentry
    services.gpg-agent = {
      enable = true;
      #enableSshSupport = true;
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
    };
  };
}
