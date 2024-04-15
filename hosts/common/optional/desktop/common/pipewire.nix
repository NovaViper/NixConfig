{
  config,
  lib,
  pkgs,
  ...
}: {
  # Enable ALSA sound
  sound.enable = true;

  # Disable PulseAudio
  hardware.pulseaudio.enable = lib.mkForce false;

  # Enable the RealtimeKit system service
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Install audio configuration tools (Especially important for VR)
  environment.systemPackages = with pkgs; [pavucontrol pulseaudio];
}
