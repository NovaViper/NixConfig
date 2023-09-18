{ config, lib, pkgs, ... }:

{
  # Enable gpg smart cards
  hardware.gpgSmartcards.enable = true;

  programs = {
    # Disable SSH Agent
    ssh.startAgent = false;

    # Make gnupg agent run with ssh support
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  services = {
    # Enable the OpenSSH daemon
    openssh.enable = true;
    # Enable PCSC-Lite daemon for Smartcard
    pcscd = {
      enable = true;
      plugins = [ pkgs.libykneomgr ];
      /* readerConfig = ''
           reader-port = "Yubico Yubi"
         '';
      */
    };
    # Install yubikey package to udev to give it usb access
    udev.packages = with pkgs; [ yubikey-personalization ];
  };

  environment = {
    systemPackages = with pkgs; [
      gnupg
      yubikey-personalization
      yubikey-personalization-gui
      yubikey-manager
      yubikey-manager-qt
    ];

    shellInit = ''
      gpg-connect-agent /bye
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    '';
  };
}
