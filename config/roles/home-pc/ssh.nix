{
  config,
  lib,
  myLib,
  username,
  ...
}:
let
  hm-config = config.hm;
in
{
  sops.secrets."networking/terminus/address" = myLib.secrets.mkSecretFile {
    source = "secrets.yaml";
    subDir = "hosts";
    owner = "root";
    mode = "0400";
  };

  sops.templates."ssh-terminus.conf" = {
    owner = username;
    mode = "0400";
    content = ''
      Host terminus
        HostName ${config.sops.placeholder."networking/terminus/address"}
      Host *
    '';
  };

  # Add in the ssh config template for terminus to the user's ssh config
  hm.programs.ssh.includes = lib.mkBefore [
    config.sops.templates."ssh-terminus.conf".path
  ];

  hm.programs.ssh.settings =
    let
      sshPath = "${hm-config.home.homeDirectory}/.ssh";
    in
    {
      "terminus" = {
        IdentityFile = [
          "${sshPath}/terminus_ed25519-sk_usba"
          "${sshPath}/terminus_ed25519-sk_usbc"
        ];
        IdentitiesOnly = true;
        Port = 22;
      };
      "knoxpc-*" = {
        HostName = "knoxpc";
        IdentityFile = [
          "${sshPath}/knox_ed25519-sk_usba"
          "${sshPath}/knox_ed25519-sk_usbc"
        ];
        Port = 22;
        RequestTTY = "yes";
        RemoteCommand = "zellij attach %n || zellij --session %n";
      };
      "knoxpc" = {
        HostName = "knoxpc";
        IdentityFile = [
          "${sshPath}/knox_ed25519-sk_usba"
          "${sshPath}/knox_ed25519-sk_usbc"
        ];
        Port = 22;
      };
      "knoxpcb" = {
        HostName = "knoxpc";
        User = "borg";
        Port = 22;
        IdentityFile = [
          "${sshPath}/borg_ed25519-sk_usba"
          "${sshPath}/borg_ed25519-sk_usbc"
        ];
      };
      "printerpi" = {
        HostName = "192.168.1.81";
        User = "exova";
        Port = 22;
      };
    };
}
