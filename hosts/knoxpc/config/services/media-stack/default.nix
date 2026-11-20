{
  config,
  lib,
  pkgs,
  username,
  ...
}:
{

  # Jellyfin runs as the primary user and shares access through this group.
  users.groups.media = { };
  users.users = {
    ${username}.extraGroups = [ "media" ];
    qbittorrent.extraGroups = [ "media" ];
    sonarr.extraGroups = [ "media" ];
    radarr.extraGroups = [ "media" ];
    lidarr.extraGroups = [ "media" ];
  };

  # Setgid shares newly created media without changing existing contents.
  # Existing Music permissions remain managed by the ACLs applied on knoxpc.
  systemd.tmpfiles.rules = [
    "d /storage/media/Library/Movies 2770 ${username} media - -"
    "d /storage/media/Library/Shows 2770 ${username} media - -"
  ];

  # Native startup settings. The applications keep their default data locations.
  services = {
    flaresolverr = {
      enable = true;
      openFirewall = false;
    };
    sonarr = {
      enable = true;
      openFirewall = false;
      settings.server.bindaddress = "127.0.0.1";
    };
    radarr = {
      enable = true;
      openFirewall = false;
      settings.server.bindaddress = "127.0.0.1";
    };
    lidarr = {
      enable = true;
      openFirewall = false;
      settings.server.bindaddress = "127.0.0.1";
    };
    prowlarr = {
      enable = true;
      package = pkgs.prowlarr-bin;
      openFirewall = false;
      settings.server.bindaddress = "127.0.0.1";
    };
    seerr = {
      enable = true;
      openFirewall = false;
      stateRevision = 1;
    };
  };

  localdns.proxies = {
    sonarr = config.services.sonarr.settings.server.port;
    radarr = config.services.radarr.settings.server.port;
    lidarr = config.services.lidarr.settings.server.port;
    prowlarr = config.services.prowlarr.settings.server.port;
    seerr = config.services.seerr.port;
  };

  systemd.services = {
    # Prowlarr reaches this proxy locally; indexers opt in with its matching tag.
    flaresolverr.environment.HOST = "127.0.0.1";
    seerr.environment.HOST = "127.0.0.1";
    sonarr = {
      unitConfig.RequiresMountsFor = [
        "/storage/media/Downloads"
        "/storage/media/Library/Shows"
      ];
      serviceConfig = {
        UMask = lib.mkForce "0007";
        StateDirectoryMode = "0700";
      };
    };
    radarr = {
      unitConfig.RequiresMountsFor = [
        "/storage/media/Downloads"
        "/storage/media/Library/Movies"
      ];
      serviceConfig.UMask = lib.mkForce "0007";
    };
    lidarr = {
      unitConfig.RequiresMountsFor = [
        "/storage/media/Downloads"
        "/storage/media/Library/Music"
      ];
      serviceConfig.UMask = "0007";
    };
  };
}
