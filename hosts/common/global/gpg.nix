{ config, lib, pkgs, ... }:

{
  # Enable gpg smart cards
  hardware.gpgSmartcards.enable = true;

  programs = {
    # Make gnupg agent run with ssh support
    gnupg.agent = {
      enable = true;
      #enableSSHSupport = true;
    };

  };

  services = {
    # Enable PCSC-Lite daemon for Smartcard
    pcscd = {
      enable = true;
      plugins = [ pkgs.libykneomgr ];
    };
    # Install yubikey package to udev to give it usb access
    udev.packages = with pkgs; [ yubikey-personalization ];
  };

  environment = {
    systemPackages = with pkgs;
      [ gnupg yubikey-personalization yubikey-manager yubico-piv-tool ]
      ++ lib.optionals (config.services.xserver.enable) [
        yubikey-personalization-gui
        yubikey-manager-qt
      ];

    /* shellInit = ''
         gpg-connect-agent /bye
         export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
       '';
    */
  };
}
