{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  cfgD = config.features.desktop;
  hm-config = config.hm;
  askpass =
    if cfgD == "kde" then
      "${lib.getExe pkgs.kdePackages.ksshaskpass}"
    else
      "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
in
{
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
    enableAskPassword = if (cfgD != null) then true else false;
    askPassword = "${askpass}";
  };

  # Enforce askpass gui when the option is enabled (based on rather x11 is running)
  environment.sessionVariables = lib.mkIf config.programs.ssh.enableAskPassword {
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  hm = {
    programs.ssh.enable = true;

    # Deprecated
    programs.ssh.enableDefaultConfig = lib.mkForce false;

    # Add machines delcared in our outputs to be have ssh hosts so we can use remote builds!
    programs.ssh.matchBlocks =
      let
        nixosConfigs = builtins.attrNames self.outputs.nixosConfigurations;
        #homeConfigs = map (n: lib.last (lib.splitString "@" n)) (builtins.attrNames self.outputs.homeConfigurations);
        matchExclusion = str: list: builtins.elem str list;
        excludedHosts = [
          "live-image"
          "iso"
          "installer"
          "knoxpc"
        ];
        hostNames =
          (attrs: builtins.filter (name: (!matchExclusion name excludedHosts)) (lib.unique attrs))
            nixosConfigs;
        #++ homeConfigs;
        matchBlocksForHosts = host: [
          {
            name = host;
            value = {
              hostname = "${host}";
              port = 22;
              identityFile =
                let
                  homePath = "${hm-config.home.homeDirectory}/.ssh";
                in
                [
                  "${homePath}/nixbuild_ed25519-sk_usba"
                  "${homePath}/nixbuild_ed25519-sk_usbc"
                ];
              extraOptions.RequestTTY = "Force";
            };
          }
        ];
      in
      builtins.listToAttrs (lib.flatten (map matchBlocksForHosts hostNames))
      // {
        "yubikey-hosts" = {
          host = "github.com gitlab.com codeberg.org";
          user = "git";
          extraOptions.PKCS11Provider = "${pkgs.opensc}/lib/opensc-pkcs11.so";
        };

        # Default options
        "*" = {
          forwardAgent = false;
          addKeysToAgent = "no";
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
        };
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
