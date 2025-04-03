{
  config,
  lib,
  myLib,
  ...
}: let
  hm-config = config.hm;
  myself = "novaviper";
in {
  hm.xdg.configFile = lib.mkMerge [
    (lib.mkIf config.modules.tmux.enable {
      "tmuxp/session.yaml" = myLib.dots.mkDotsSymlink {
        config = hm-config;
        user = myself;
        source = "tmuxp/session.yaml";
      };
    })
  ];

  #hm.programs.tmux.which-key.settings = import ./which-key-config.nix;
}
