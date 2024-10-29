{
  config,
  lib,
  pkgs,
  ...
}: let
  desktopW = config.services.desktopManager;

  askpass =
    if (desktopW.plasma6.enable)
    then "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass"
    else "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
in {
  # Enable the OpenSSH daemon
  services.openssh = {
    enable = true;
    settings = {
      #Harden
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      # Automatically remove stale sockets
      StreamLocalBindUnlink = "yes";
    };
  };

  programs.ssh = {
    startAgent = true;
    askPassword = "${askpass}";
  };

  # Enforce askpass gui when the option is enabled (based on rather x11 is running)
  /*
  environment.sessionVariables =
  lib.mkIf (config.programs.ssh.enableAskPassword) {
    SSH_ASKPASS_REQUIRE = "prefer";
  };
  */

  hm = {
    programs.ssh = {
      enable = true;
    };

    # NOTE https://github.com/nix-community/home-manager/issues/322#issuecomment-1856128020
    home.file.".ssh/config" = {
      target = ".ssh/config_source";
      onChange = ''cat ~/.ssh/config_source > ~/.ssh/config && chmod 400 ~/.ssh/config'';
    };

    home.shellAliases = {
      # Remove all identities
      remove-ssh-keys = "ssh-add -D";
      # List all SSH keys in the agent
      list-ssh-key = "ssh-add -L";
    };
  };
}
