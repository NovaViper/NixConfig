{
  config,
  lib,
  pkgs,
  self,
  ...
}: let
  desktopW = config.services.desktopManager;

  askpass =
    if desktopW.plasma6.enable
    then "${lib.getExe pkgs.kdePackages.ksshaskpass}"
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
    programs.ssh.enable = true;

    # Add machines delcared in our outputs to be have ssh hosts so we can use remote builds!
    programs.ssh.matchBlocks = let
      nixosConfigs = builtins.attrNames self.outputs.nixosConfigurations;
      homeConfigs = map (n: lib.last (lib.splitString "@" n)) (builtins.attrNames self.outputs.homeConfigurations);
      hostNames =
        (attrs:
          builtins.filter (name: (name != "live-image" && name != "iso"))
          (lib.unique attrs))
        nixosConfigs
        ++ homeConfigs;
      matchBlocksForHosts = host: [
        {
          name = host;
          value = {
            hostname = "${host}";
            port = 22;
            identityFile = "${config.hm.home.homeDirectory}/.ssh/id_ed25519_sk_rk_nixbuilder";
            extraOptions.RequestTTY = "Force";
          };
        }
      ];
    in
      builtins.listToAttrs (lib.flatten (map matchBlocksForHosts hostNames));

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
