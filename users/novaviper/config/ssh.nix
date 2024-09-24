{config, ...}: {
  programs.ssh.matchBlocks = {
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
}
