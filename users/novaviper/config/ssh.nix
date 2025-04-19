{
  config,
  pkgs,
  ...
}: {
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
    "yubikey-hosts" = {
      host = "github.com gitlab.com codeberg.org";
      identitiesOnly = true;
      extraOptions.PKCS11Provider = "${pkgs.opensc}/lib/pkcs11/opensc-pkcs11.so";
      #port = 22;
      #user = "git";
    };
  };
}
