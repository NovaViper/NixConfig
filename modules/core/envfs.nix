{pkgs, ...}: {
  # NOTE This breaks with the iso image!
  services.envfs.enable = true;
  programs.nix-ld.enable = true;
  /*
    programs.nix-ld.libraries = with pkgs; [
    # Needed for operating system detection until
    # https://github.com/ValveSoftware/steam-for-linux/issues/5909 is resolved
    lsb-release
    # Errors in output without those
    pciutils
    # Open URLs
    xdg-utils
  ];
  */
}
