{
  config,
  lib,
  pkgs,
  ...
}: {
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
}
