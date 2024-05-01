{
  config,
  lib,
  pkgs,
  ...
}: {
  services = {
    # Enable touchpad support
    libinput.enable = true;

    # Enable the X11 windowing system.
    xserver = {
      enable = true;

      # Configure keymap in X11
      xkb = {
        layout = "us";
        variant = "";
        options = "terminate:ctrl_alt_bksp,caps:ctrl_modifier";
      };

      # Remove xterm terminal
      excludePackages = with pkgs; [xterm];
    };
  };

  # Install installation
  environment.systemPackages = with pkgs; [
    # X11
    xorg.xkbutils
    xorg.xkill
    xorg.libxcb
  ];
}
