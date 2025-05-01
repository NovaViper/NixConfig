{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Config for WiVRn (https://github.com/WiVRn/WiVRn/blob/master/docs/configuration.md)
  # Steam launch args: PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/wivrn_comp_ipc %command%
  services.wivrn.config.json = {
    # 50 Mb/s, default setting and seems to be the best for Beat Saber
    bitrate = 50 * 1000000;
    # 0.5x (50%) foveation scaling, don't need it super high because it makes latency higher (which is bad for Beat Saber)
    # Lower value means higher foveation
    scale = 0.5;
    encoders = [
      {
        encoder = "nvenc";
        codec = "h265";
        # 1.0 x 1.0 scaling, using the defaults
        width = 1.0;
        height = 1.0;
        offset_x = 0.0;
        offset_y = 0.0;
      }
    ];
    application = [ pkgs.wlx-overlay-s ];
  };
}
