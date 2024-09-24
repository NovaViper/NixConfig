{
  outputs,
  config,
  pkgs,
  ...
}:
outputs.lib.mkModule config "gpg" {
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

  nixos = {
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
