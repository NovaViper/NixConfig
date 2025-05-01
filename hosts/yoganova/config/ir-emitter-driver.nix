{ pkgs, ... }:
let
  ir_config = pkgs.writeText "pci-0000:00:14.0-usb-0:6:1.2-video-index0_emitter0.driver" ''
    device=/dev/v4l/by-path/pci-0000:00:14.0-usb-0:6:1.2-video-index0
    unit=7
    selector=6
    control0=1
    control1=3
    control2=2
    control3=0
    control4=0
    control5=0
    control6=0
    control7=0
    control8=0
  '';
in
{
  system.activationScripts.copySysConfigs =
    let
      folder = "/etc/linux-enable-ir-emitter";
    in
    ''
      mkdir -p ${folder}
      if [ -z "$(ls -A ${folder})" ]; then
         cp ${ir_config} ${folder}/pci-0000:00:14.0-usb-0:6:1.2-video-index0_emitter0.driver
      fi
    '';

  # Set IR blaster device
  #services.linux-enable-ir-emitter.device = "video2";
}
