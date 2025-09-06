{
  config,
  pkgs,
  ...
}:
{
  programs.ssh.matchBlocks = {
    "knoxpc-*" = {
      hostname = "192.168.1.120";
      identityFile = "${config.home.homeDirectory}/.ssh/id_ecdsa_sk_rk_knox";
      port = 22;
      extraOptions = {
        RequestTTY = "yes";
        RemoteCommand = "tmux new-session -A -s \${%n}";
      };
    };
    "knoxpc" = {
      hostname = "192.168.1.120";
      identityFile = "${config.home.homeDirectory}/.ssh/id_ecdsa_sk_rk_knox";
      port = 22;
    };
    "knoxpcb" = {
      hostname = "192.168.1.120";
      user = "borg";
      port = 22;
      identityFile = [
        "${config.home.homeDirectory}/.ssh/id_ed25519_sk_rk_borgPCA"
        "${config.home.homeDirectory}/.ssh/id_ed25519_sk_rk_borgPCC"
      ];
    };
    "printerpi" = {
      hostname = "192.168.1.81";
      user = "exova";
      port = 22;
    };
  };
}
