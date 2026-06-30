{ config, username, ... }:
let
  user = username;
  base = config.users.users.${user};
  group = base.group;
  directories = [ "/storage/media/Sync" ];
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
    dataDir = "/storage/media/Sync";
    # TODO Maybe move this later
    #configDir = "/storage/services/syncthing";
  };

  # GUI
  networking.firewall.allowedTCPPorts = [ 8384 ];
}
