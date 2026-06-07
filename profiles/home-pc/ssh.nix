{
  config,
  pkgs,
  ...
}:
let
  hm-config = config.hm;
in
{
  hm.programs.ssh.settings =
    let
      homePath = "${hm-config.home.homeDirectory}/.ssh";
    in
    {
      "knoxpc-*" = {
        HostName = "192.168.1.120";
        IdentityFile = [
          "${homePath}/knox_ed25519-sk_usba"
          "${homePath}/knox_ed25519-sk_usbc"
        ];
        Port = 22;
        RequestTTY = "yes";
        RemoteCommand = "tmux new-session -A -s \${%n}";
      };
      "knoxpc" = {
        HostName = "192.168.1.120";
        IdentityFile = [
          "${homePath}/knox_ed25519-sk_usba"
          "${homePath}/knox_ed25519-sk_usbc"
        ];
        Port = 22;
      };
      "knoxpcb" = {
        HostName = "192.168.1.120";
        User = "borg";
        Port = 22;
        IdentityFile = [
          "${homePath}/borg_ed25519-sk_usba"
          "${homePath}/borg_ed25519-sk_usbc"
        ];
      };
      "printerpi" = {
        HostName = "192.168.1.81";
        User = "exova";
        Port = 22;
      };
    };
}
