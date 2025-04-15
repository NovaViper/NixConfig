{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # Terminal Decorations
    toilet # Display fancy text in terminal
    dwt1-shell-color-scripts # Display cool graphics in terminal
  ];

  programs.zsh = {
    initContent = lib.mkMerge [
      (lib.optionalString config.programs.tmux.enable (lib.mkOrder 450
        ''
          # Run Tmux on startup OUTSIDE of SSH
          if [ -z "$TMUX" ] && [ -z "$SSH_CONNECTION" ]; then
            ${lib.getExe pkgs.tmux} attach >/dev/null 2>&1 || ${lib.getExe pkgs.tmuxp} load ${config.xdg.configHome}/tmuxp/session.yaml >/dev/null 2>&1
            exit
          fi
        ''))
      (lib.mkOrder 5000 ''
        # Create shell prompt
        if [ $(tput cols) -ge '75' ] || [ $(tput cols) -ge '100' ]; then
          ${lib.getExe pkgs.toilet} -f pagga "FOSS AND BEAUTIFUL" --metal
          ${lib.getExe pkgs.fastfetch}
        fi
      '')
    ];
  };
}
