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
    startAgent = cfgD.startAgent;
    enableAskPassword = cfgD.askpassProgram != null;
    askPassword = cfgD.askpassProgram;
  };

  # Enforce askpass gui when the option is enabled (based on rather x11 is running)
  environment.sessionVariables = lib.mkIf (config.features.desktop.askpassProgram != null) {
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  hm = {
    programs.ssh.enable = true;

    # Deprecated
    programs.ssh.enableDefaultConfig = lib.mkForce false;

    # Add machines delcared in our outputs to be have ssh hosts so we can use remote builds!
    programs.ssh.settings =
      let
        nixosConfigs = builtins.attrNames self.outputs.nixosConfigurations;
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
        matchBlocksForHosts = host: [
          {
            name = host;
            value = {
              HostName = "${host}";
              Port = 22;
              IdentityFile =
                let
                  homePath = "${hm-config.home.homeDirectory}/.ssh";
                in
                [
                  "${homePath}/nixbuilder_ed25519-sk_usba"
                  "${homePath}/nixbuilder_ed25519-sk_usbc"
                ];
              RequestTTY = "Force";
            };
          }
        ];
      in
      builtins.listToAttrs (lib.flatten (map matchBlocksForHosts hostNames))
      // {
        "yubikey-hosts" = {
          Host = "github.com gitlab.com codeberg.org";
          User = "git";
          PKCS11Provider = "${pkgs.opensc}/lib/opensc-pkcs11.so";
        };

        # Default options
        "*" = {
          ForwardAgent = false;
          AddKeysToAgent = "no";
          Compression = false;
          ServerAliveInterval = 0;
          ServerAliveCountMax = 3;
          HashKnownHosts = false;
          UserKnownHostsFile = "~/.ssh/known_hosts";
          ControlMaster = "no";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "no";
        };
      };

    # HACK: https://github.com/nix-community/home-manager/issues/322#issuecomment-1856128020
    home.file.".ssh/config" = {
      target = ".ssh/config_source";
      onChange = "cat ~/.ssh/config_source > ~/.ssh/config && chmod 400 ~/.ssh/config";
    };

    home.shellAliases = {
      # Remove all identities
      remove-ssh-keys = "ssh-add -D";
      # List all SSH keys in the agent
      list-ssh-key = "ssh-add -L";
    };
  };
}
