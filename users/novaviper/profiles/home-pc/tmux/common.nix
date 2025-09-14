{
  config,
  lib,
  myLib,
  ...
}:
let
  user = "novaviper";
  hm-config = config.hm;
in
{
  hm.xdg.configFile = lib.mkMerge [
    (lib.mkIf hm-config.programs.tmux.enable {
      "tmuxp/session.yaml" = myLib.dots.mkDotsSymlink {
        inherit user;
        config = hm-config;
        source = "tmuxp/session.yaml";
      };
    })
  ];
  #hm.programs.tmux.which-key.settings = import ./which-key-config.nix;
}
