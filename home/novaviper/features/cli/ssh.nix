{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "knoxpi-*" = {
        hostname = "192.168.1.101";
        identityFile = "${config.home.homeDirectory}/.ssh/id_ecdsa_sk_rk_knox";
        port = 22;
        extraOptions = {
          RequestTTY = "yes";
          RemoteCommand = "tmux new-session -A -s \${%n}";
        };
      };
      "knoxpi" = {
        hostname = "192.168.1.101";
        identityFile = "${config.home.homeDirectory}/.ssh/id_ecdsa_sk_rk_knox";
        port = 22;
      };
      "printerpi" = {
        user = "exova";
        hostname = "192.168.1.81";
        port = 22;
      };
    };
  };

  home.shellAliases = {
    # Remove all identities
    remove-ssh-keys = "ssh-add -D";
    # List all SSH keys in the agent
    list-ssh-key = "ssh-add -L";
  };
}
