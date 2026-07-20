{
  config,
  lib,
  pkgs,
  ...
}:
let
  hm-config = config.hm;
in
{
  hm.home.packages = with pkgs; [
    # Terminal Decorations
    toilet # Display fancy text in terminal
    dwt1-shell-color-scripts # Display cool graphics in terminal
  ];
  hm.programs.fish = {
    # interactiveShellInit = lib.mkAfter (
    #   lib.concatStringsSep "\n" [
    #     (lib.optionalString hm-config.programs.tmux.enable # fish
    #       ''
    #         # Run Tmux on startup OUTSIDE of SSH
    #         if test -z "$TMUX"
    #            and test -z "$SSH_CONNECTION"
    #            ${lib.getExe pkgs.tmux} attach >/dev/null 2>&1 || exec ${lib.getExe pkgs.tmuxp} load ${hm-config.xdg.configHome}/tmuxp/session.yaml >/dev/null 2>&1
    #         end
    #       ''
    #     )
    #   ]
    # );

    functions = {
      fish_greeting = # fish
        ''
          sleep 0.1 # Delay slightly to allow for tput to measure the panes
          set -l cols (tput cols)
          if test $cols -ge 75
              or test $cols -ge 100
            ${lib.getExe pkgs.toilet} -f pagga "FOSS AND BEAUTIFUL" --metal
            ${lib.getExe pkgs.fastfetch}
          end
        '';
      reload = {
        description = "Reload the shell";
        body = # fish
          ''
            clear
            exec fish
          '';
      };
      list-keys = {
        argumentNames = lib.singleton "prog";
        description = "List the keybindings for various programs Supported: wezterm, alacritty, tmux";
        body = # fish
          ''
            # First check if argument was provided
            if test -z "$prog"
                echo "Error: Input must be a non-empty string."
                return 1
            end

            switch (string lower "$prog")
                case "wezterm"
                    xdg-open "https://wezfurlong.org/wezterm/config/default-keys.html" &>/dev/null
                case "alacritty"

                    xdg-open "https://github.com/alacritty/alacritty/blob/master/alacritty.yml" &>/dev/null
                case "tmux"

                    xdg-open "https://gist.github.com/mzmonsour/8791835#file-tmux-default-bindings-txt" &>/dev/null
                case '*'
                    echo "Error: Invalid input. Available options are: wezterm, alacritty, tmux"
                    return 1
            end
          '';
      };
    };
  };

  hm.programs.zsh = {
    initContent = lib.mkMerge [
      # (lib.optionalString hm-config.programs.tmux.enable (
      #   lib.mkOrder 450 ''
      #     # Run Tmux on startup OUTSIDE of SSH
      #     if [ -z "$TMUX" ] && [ -z "$SSH_CONNECTION" ]; then
      #       ${lib.getExe pkgs.tmux} attach >/dev/null 2>&1 || ${lib.getExe pkgs.tmuxp} load ${hm-config.xdg.configHome}/tmuxp/session.yaml >/dev/null 2>&1
      #       exit
      #     fi
      #   ''
      # ))
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
