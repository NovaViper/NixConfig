{
  config,
  lib,
  myLib,
  ...
}: let
  hm-config = config.hm;
in {
  create.configFile = lib.mkMerge [
    (lib.mkIf config.modules.tmux.enable {
      "tmuxp/session.yaml" = myLib.dots.mkDotsSymlink {
        config = hm-config;
        user = hm-config.home.username;
        source = "tmuxp/session.yaml";
      };
    })
  ];

  #hm.programs.tmux.which-key.settings = import ./which-key-config.nix;
}
