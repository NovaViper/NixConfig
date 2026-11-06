{
  config,
  lib,
  username,
  ...
}:
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
  localdns.proxies.syncthing = 8384;

  # Syncthing's loopback GUI rejects the public hostname in the Host header.
  # Override the generated proxy to send Host: 127.0.0.1:8384, preserving its host check.
  services.caddy.virtualHosts."https://syncthing.${config.localdns.domain}".extraConfig =
    lib.mkForce ''
      tls internal
      import lan_only
      reverse_proxy 127.0.0.1:8384 {
        header_up Host {upstream_hostport}
        header_up X-Real-IP {remote_host}
      }
    '';

  systemd.tmpfiles.rules = map (x: "d ${x.path} ${x.mode} ${user} ${group} - -") directories;

  services.syncthing = {
    inherit user;
    enable = true;
    guiAddress = "127.0.0.1:8384";
    # Caddy terminates HTTPS and proxies over HTTP to the loopback-only GUI
    settings.gui.tls = false;
    overrideFolders = false;
    overrideDevices = false;
    dataDir = "/storage/media/Sync";
    configDir = "/storage/services/syncthing";
  };
}
