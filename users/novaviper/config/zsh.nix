{
  config,
  lib,
  myLib,
  pkgs,
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

  home.packages = with pkgs; [
    # Terminal Decorations
    toilet # Display fancy text in terminal
    dwt1-shell-color-scripts # Display cool graphics in terminal
  ];

  hm.programs.zsh = {
    initExtraFirst = lib.mkAfter (lib.concatStringsSep "\n" [
      (lib.optionalString hm-config.programs.tmux.enable
        ''
          # Run Tmux on startup
          if [ -z "$TMUX" ]; then
            ${pkgs.tmux}/bin/tmux attach >/dev/null 2>&1 || ${pkgs.tmuxp}/bin/tmuxp load ${hm-config.xdg.configHome}/tmuxp/session.yaml >/dev/null 2>&1
            exit
          fi
        '')
    ]);

    initExtra = lib.mkAfter (lib.concatStringsSep "\n" [
      ''
        # Create shell prompt
        if [ $(tput cols) -ge '75' ] || [ $(tput cols) -ge '100' ]; then
          ${pkgs.toilet}/bin/toilet -f pagga "FOSS AND BEAUTIFUL" --metal
          ${pkgs.fastfetch}/bin/fastfetch
        fi
      ''
    ]);
  };
}
