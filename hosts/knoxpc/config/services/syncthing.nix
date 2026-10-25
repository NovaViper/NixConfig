{ config, username, ... }:
let
  user = username;
  base = config.users.users.${user};
  group = base.group;
  directories = [
    {
      path = "/storage/media/Sync";
      mode = "0770";
    }
    {
      path = "/storage/services/syncthing";
      mode = "0700";
    }
  ];
in
{
  systemd.tmpfiles.rules = map (x: "d ${x.path} ${x.mode} ${user} ${group} - -") directories;

  services.syncthing = {
    inherit user;
    enable = true;
    #openDefaultPorts = true;
    guiAddress = "0.0.0.0:8384";
    overrideFolders = false;
    overrideDevices = false;
    dataDir = "/storage/media/Sync";
    configDir = "/storage/services/syncthing";
  };

  # GUI
  networking.firewall.allowedTCPPorts = [ 8384 ];
}
