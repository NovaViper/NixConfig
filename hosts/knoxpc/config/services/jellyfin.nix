{
  config,
  pkgs,
  username,
  ...
}:
let
  user = username;
  group = base.group;
  base = config.users.users.${user};
in
{
  localdns.proxies.jellyfin = 8096;

  # Coffee Lake UHD 630 uses Intel's iHD VA-API driver
  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.intel-media-driver ];
  };

  systemd.services.jellyfin.serviceConfig.SupplementaryGroups = [
    "render"
    "video"
  ];

  systemd.tmpfiles.rules = [
    "d /storage/media/Library 0755 ${user} ${group} - -"
  ];

  services.jellyfin = {
    enable = true;
    user = user;
    group = group;

    hardwareAcceleration = {
      enable = true;
      type = "vaapi";
      device = "/dev/dri/renderD128";
    };

    # Apply these settings on restart; the module backs up existing encoding.xml
    forceEncodingConfig = true;
    transcoding = {
      enableHardwareEncoding = true;
      # HDR tone mapping needs a separately configured OpenCL runtime
      enableToneMapping = false;
      hardwareDecodingCodecs = {
        h264 = true;
        hevc = true;
        hevc10bit = true;
        mpeg2 = true;
        vc1 = true;
        vp8 = true;
        vp9 = true;
      };
    };

    # For internal access
    openFirewall = true;
  };
}
