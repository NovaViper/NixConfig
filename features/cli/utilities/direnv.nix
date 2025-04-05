_: {
  # Shell extension to load and unload environment variables depending on the current directory.
  hm.programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    #config = {};
    stdlib = ''export DIRENV_ACTIVE=1'';
  };
}
