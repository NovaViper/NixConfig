{
  config,
  pkgs,
  ...
}:
let
  hm-config = config.hm;
in
{
  hm.programs.ssh.matchBlocks =
    let
      homePath = "${hm-config.home.homeDirectory}/.ssh";
    in
    {
      "knoxpc-*" = {
        hostname = "192.168.1.120";
        identityFile = [
          "${homePath}/id_ecdsa_sk_rk_knox"
          "${homePath}/knox_ed25519-sk_usbc"
        ];
        port = 22;
        extraOptions = {
          RequestTTY = "yes";
          RemoteCommand = "tmux new-session -A -s \${%n}";
        };
      };
      "knoxpc" = {
        hostname = "192.168.1.120";
        identityFile = [
          "${homePath}/id_ecdsa_sk_rk_knox"
          "${homePath}/knox_ed25519-sk_usbc"
        ];
        port = 22;
      };
      "knoxpcb" = {
        hostname = "192.168.1.120";
        user = "borg";
        port = 22;
        identityFile = [
          "${homePath}/id_ed25519_sk_rk_borgPCA"
          "${homePath}/borg_ed25519-sk_usbc"
        ];
      };
      "printerpi" = {
        hostname = "192.168.1.81";
        user = "exova";
        port = 22;
      };
    };
}
