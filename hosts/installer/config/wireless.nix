{
  config,
  lib,
  pkgs,
  ...
}: {
  # override installation-cd-base and enable wpa and sshd start at boot
  systemd.services.wpa_supplicant.wantedBy = lib.mkForce ["multi-user.target"];
  systemd.services.sshd.wantedBy = lib.mkForce ["multi-user.target"];

  services.openssh = {
    ports = [22];
    # Allow root login for SSH
    settings.PermitRootLogin = lib.mkForce "yes";
  };
}
