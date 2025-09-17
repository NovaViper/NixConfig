{
  config,
  lib,
  pkgs,
  myLib,
  ...
}:
let
  user = "novaviper";
  hm-config = config.hm;
  ghosttyCommand =
    pkgs.writeShellScript "ghostty-tmux"
      # bash
      ''
        ${lib.getExe pkgs.tmux} attach >/dev/null 2>&1 || ${lib.getExe pkgs.tmuxp} load ${hm-config.xdg.configHome}/tmuxp/session.yaml >/dev/null 2>&1

        $SHELL
      '';

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

  hm.programs.ghostty.settings = lib.mkIf hm-config.programs.tmux.enable {
    command = builtins.toString ghosttyCommand;
  };

  #hm.programs.tmux.which-key.settings = import ./which-key-config.nix;
}
