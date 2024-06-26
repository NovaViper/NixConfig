{
  config,
  lib,
  pkgs,
  ...
}: let
  desktopX = config.services.xserver.desktopManager;
  desktopW = config.services.desktopManager;

  askpass =
    if (desktopX.plasma5.enable)
    then "${pkgs.libsForQt5.ksshaskpass}/bin/ksshaskpass"
    else if (desktopW.plasma6.enable)
    then "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass"
    else "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
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
  };

  programs.ssh = {
    startAgent = true;
    askPassword = "${askpass}";
  };

  # Enforce askpass gui when the option is enabled (based on rather x11 is running)
  /*
  environment.sessionVariables =
  lib.mkIf (config.programs.ssh.enableAskPassword) {
    SSH_ASKPASS_REQUIRE = "prefer";
  };
  */
}
