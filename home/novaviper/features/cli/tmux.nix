{ config, lib, pkgs, ... }:

{

  xdg.configFile = {
    "tmuxp/session.yaml".source = ../../dots/tmuxp/session.yaml;
  };

  programs = {

    fzf.tmux.enableShellIntegration = true;
    tmux = {
      enable = true;
      historyLimit = 5000;
      keyMode = "vi";
      mouse = true;
      escapeTime = 0;
      prefix = "C-a";
      terminal = "xterm-256color";
      #shell = "${pkgs.zsh}/bin/zsh";
      #newSession = true;
      #secureSocket = false;
      resizeAmount = 15;
      baseIndex = 1;
      tmuxp.enable = true;
      extraConfig = ''
        # -- more settings ---------------------------------------------------------------
        set -s set-clipboard on
        set -g set-titles on

        # Pane numbers, line messages duration and status line updates
        set -g display-panes-time 800
        set -g display-time 1000
        set -g status-interval 10

        # Monitor for terminal activity changes, and manage how the alerts are displayed
        set -g monitor-activity on
        set -g visual-activity both

        # update files on focus
        set -g focus-events on

        setw -g automatic-rename on
        # Renumber windows
        set -g renumber-windows on

        # Change status bar position
        #set -g status-position bottom

        # -- keybindings -----------------------------------------------------------------
        # reload config file (change file location to your the tmux.conf you want to use)
        bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

        # Setup clipboard binding keys
        unbind p
        bind-key -T copy-mode-vi 'v' send -X begin-selection
        bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel
        bind-key p paste-buffer
        bind-key P previous-window # make old previous window command use P instead of p

        # switch panes using Alt-arrow without prefix
        bind -n M-Left select-pane -L
        bind -n M-Right select-pane -R
        bind -n M-Up select-pane -U
        bind -n M-Down select-pane -D

        # split panes using - and _
        bind-key "|" split-window -h -c "#{pane_current_path}"
        bind-key "\\" split-window -fh -c "#{pane_current_path}"

        bind-key "-" split-window -v -c "#{pane_current_path}"
        bind-key "_" split-window -fv -c "#{pane_current_path}"
        unbind '"'
        unbind %

        # Swap windows
        bind -r "<" swap-window -d -t -1
        bind -r ">" swap-window -d -t +1

        # Keep current path
        bind c new-window -c "#{pane_current_path}"
        # Toggle between windows
        bind Space last-window
        # Toggle between the current and the previous session
        bind-key C-Space switch-client -l
        # Jump to marked session
        bind \` switch-client -t'{marked}'

        # Join panes horizontally (j) and vertically (J)
        bind j choose-window 'join-pane -h -s "%%"'
        bind J choose-window 'join-pane -s "%%"'

        bind X confirm-before -p "kill-window #W? (y/n)" kill-window
        bind C-x confirm-before -p "kill-session #W? (y/n)" kill-session

        bind C-c new-session

        #Example
        #bind-key h split-window -h "vim ~/scratch/notes.md"
      '';
      plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
        {
          plugin = dracula;
          extraConfig = ''
            # Theme settings
            # available plugins: battery, cpu-usage, git, gpu-usage, ram-usage, network, network-bandwidth, network-ping, attached-clients, network-vpn, weather, time, spotify-tui, kubernetes-context
            set -g @dracula-plugins "battery weather gpu-usage git time"

            # Show powerline symbols
            set -g @dracula-show-powerline false

            # Enable window flags
            set -g @dracula-show-flags true

            # Switch left icon, can accept `session`, `smiley`, `window`, or any character.
            set -g @dracula-show-left-icon smiley

            # Hide empty plugins
            set -g @dracula-show-empty-plugins false

            # Theme color settings
            # available colors: white, gray, dark_gray, light_purple, dark_purple, cyan, green, orange, red, pink, yellow
            # set -g @dracula-[plugin-name]-colors "[background] [foreground]"
            set -g @dracula-gpu-usage-colors "red white"
          '';
        }
        /* {
                plugin = tmux-nova;
                extraConfig = ''
                  # -- theme -----------------------------------------------------------------
                  # Dracula Color Palette
                  white='#f8f8f2'
                  gray='#44475a'
                  dark_gray='#282a36'
                  light_purple='#bd93f9'
                  dark_purple='#6272a4'
                  cyan='#8be9fd'
                  green='#50fa7b'
                  orange='#ffb86c'
                  red='#ff5555'
                  pink='#ff79c6'
                  yellow='#f1fa8c'

                  set -g @nova-nerdfonts false

                  # Colors
                  set -gw window-status-current-style bold
                  set -g "@nova-status-style-bg" "$gray"
                  set -g "@nova-status-style-fg" "$white"
                  set -g "@nova-status-style-active-bg" "$dark_purple"
                  set -g "@nova-status-style-active-fg" "$white"

                  set -g "@nova-pane-active-border-style" "$orange"
                  set -g "@nova-pane-border-style" "$gray"

                  # Declare Status
                  set -g @nova-segment-mode "#{?client_prefix,Ω,ω}"
                  set -g @nova-segment-mode-colors "$green $dark_gray"

                  set -g @nova-segment-whoami "#(whoami)@#h"
                  set -g @nova-segment-whoami-colors "$light_purple $white"

                  set -g @nova-pane "#I#{?pane_in_mode,  #{pane_mode},}  #W"

                  # Declare system info
                  set -g @nova-segment-cpu " #{cpu_percentage} #{ram_percentage}"
                  set -g @nova-segment-cpu-colors "$pink $dark_gray"

                  set -g @batt_icon_status_charging '↑'
                  set -g @batt_icon_status_discharging '↓'
                  set -g @nova-segment-battery "#{battery_icon_status} #{battery_percentage}"
                  set -g @nova-segment-battery-colors "$red $dark_gray"

                  set -g @nova-rows 0
                  set -g @nova-segments-0-left "mode"
                  set -g @nova-segments-0-right "cpu battery whoami"
                '';
              }
           cpu
        */
      ];
    };
  };
}
