{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:
with lib; {
  xdg.configFile = mkMerge [
    (mkIf osConfig.modules.zsh.enable {
      "zsh/.p10k.zsh" = dots.mkDotsSymlink {
        inherit config;
        user = config.home.username;
        source = "zsh/.p10k.zsh";
      };
      "zsh/functions" = dots.mkDotsSymlink {
        inherit config;
        user = config.home.username;
        source = "zsh/functions";
      };
    })

    (mkIf config.modules.tmux.enable {
      "tmuxp/session.yaml" = dots.mkDotsSymlink {
        inherit config;
        user = config.home.username;
        source = "tmuxp/session.yaml";
      };
    })
  ];

  programs.zsh = {
    initExtraFirst = lib.mkAfter ''
      ${
        if config.modules.tmux.enable
        then ''
          # Run Tmux on startup
          if [ -z "$TMUX" ]; then
            ${pkgs.tmux}/bin/tmux attach >/dev/null 2>&1 || ${pkgs.tmuxp}/bin/tmuxp load ${config.xdg.configHome}/tmuxp/session.yaml >/dev/null 2>&1
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
