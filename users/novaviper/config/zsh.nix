{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:
with lib; let
  hm-config = config.hm;
in {
  create.configFile = mkMerge [
    (mkIf config.modules.tmux.enable {
      "tmuxp/session.yaml" = dots.mkDotsSymlink {
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
    initExtraFirst = lib.mkAfter ''
      ${
        if config.modules.tmux.enable
        then ''
          # Run Tmux on startup
          if [ -z "$TMUX" ]; then
            ${pkgs.tmux}/bin/tmux attach >/dev/null 2>&1 || ${pkgs.tmuxp}/bin/tmuxp load ${hm-config.xdg.configHome}/tmuxp/session.yaml >/dev/null 2>&1
            exit
          fi
        ''
        else ""
      }
    '';
    initExtra = lib.mkAfter ''
      # Create shell prompt
      if [ $(tput cols) -ge '75' ] || [ $(tput cols) -ge '100' ]; then
        ${pkgs.toilet}/bin/toilet -f pagga "FOSS AND BEAUTIFUL" --metal
        ${pkgs.fastfetch}/bin/fastfetch
      fi
    '';
  };
}
