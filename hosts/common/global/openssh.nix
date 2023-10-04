{ config, lib, pkgs, ... }:
let
  desktop = config.services.xserver.desktopManager;

  askpass = if (desktop.plasma5.enable) then {
    pass = "${pkgs.libsForQt5.ksshaskpass}/bin/ksshaskpass";
  } else {
    pass = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
  };

  # Sops needs acess to the keys before the persist dirs are even mounted; so
  # just persisting the keys won't work, we must point at /persist
  hasOptinPersistence = config.environment.persistence ? "/persist";
in {
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
    /* hostKeys = [{
         path = "${
             lib.optionalString hasOptinPersistence "/persist"
           }/etc/ssh/ssh_host_ed25519_key";
         type = "ed25519";
       }];
    */
  };

  programs.ssh = {
    startAgent = true;
    # Allows PKCS11 Keys on Yubikey to be used for ssh authentication
    agentPKCS11Whitelist = "${pkgs.opensc}/lib/opensc-pkcs11.so";
    askPassword = "${askpass.pass}";
  };

  # Enforce askpass gui when the option is enabled (based on rather x11 is running)
  environment.sessionVariables =
    lib.mkIf (config.programs.ssh.enableAskPassword) {
      SSH_ASKPASS_REQUIRE = "prefer";
    };
}
