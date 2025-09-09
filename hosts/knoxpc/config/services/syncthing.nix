{ config, username, ... }:
let
  user = username;
  base = config.users.users.${user};
  group = base.group;
  directories = [ "/mnt/media/Sync" ];
in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0770 ${user} ${group} - -") directories;

  services.syncthing = {
    inherit user;
    enable = true;
    #openDefaultPorts = true;
    guiAddress = "0.0.0.0:8384";
    overrideFolders = false;
    overrideDevices = false;
    dataDir = "/mnt/media/Sync";
    # TODO Maybe move this later
    #configDir = "/mnt/docker/syncthing";
  };

  # GUI
  networking.firewall.allowedTCPPorts = [ 8384 ];
}
