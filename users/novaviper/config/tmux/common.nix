{
  config,
  lib,
  myLib,
  ...
}: let
  myself = "novaviper";
in {
  xdg.configFile = lib.mkMerge [
    (lib.mkIf config.programs.tmux.enable {
      "tmuxp/session.yaml" = myLib.dots.mkDotsSymlink {
        config = config;
        user = myself;
        source = "tmuxp/session.yaml";
      };
    })
  ];
  #programs.tmux.which-key.settings = import ./which-key-config.nix;
}
