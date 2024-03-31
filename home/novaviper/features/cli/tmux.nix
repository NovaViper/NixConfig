{ config, lib, pkgs, ... }:
let
  cfg = config.programs.tmux;
  c = config.lib.stylix.colors.withHashtag;
in {

  xdg.configFile = {
    "tmuxp/session.yaml".source = ../../dots/tmuxp/session.yaml;
  };

  programs = {
    # Fixes issue where cava can't run under tmux
    zsh.shellAliases = lib.mkIf (config.programs.cava.enable) {
      cava = "TERM=xterm-256color cava";
    };
    fzf.tmux.enableShellIntegration =
      lib.mkIf (config.programs.fzf.enable) true;
    tmux = {
      enable = true;
      aggressiveResize = true;
      customPaneNavigationAndResize = true;
      baseIndex = 1;
      historyLimit = 5000;
      keyMode = "vi";
      mouse = true;
      #escapeTime = 0;
      shortcut = "a";
      terminal = "tmux-256color";
      resizeAmount = 15;
      tmuxp.enable = true;
      #newSession = true;
      #secureSocket = false;
      extraConfig = ''
        # -- more settings ---------------------------------------------------------------
        set -s set-clipboard on
        set -g set-titles on
        set -g set-titles-string "#S / #W / #(pwd)"
        set -g allow-passthrough on
        set-option -g status-right-length 100

        # Enable sixel support
        set -as terminal-features 'contour:sixel'

        # Enable full RGB support
        set -as terminal-features ",*-256color:RGB"

        # Pane numbers, line messages duration and status line updates
        set -g display-panes-time 800
        set -g display-time 2000
        set -g status-interval 5

        # Monitor for terminal activity changes, and manage how the alerts are displayed
        set -g monitor-activity on
        set -g visual-activity both

        # update files on focus
        set -g focus-events on

        setw -g automatic-rename on
        # Renumber windows
        set -g renumber-windows on

        # Change status bar position
        set -g status-position bottom
        # -------------------------------------------------------------------------------------


        # -- keybindings -----------------------------------------------------------------
        # reload config file (change file location to your the tmux.conf you want to use)
        unbind R
        bind -N "Reload configuration" r source-file ${config.xdg.configHome}/tmux/tmux.conf \; display "Reloaded!"

        unbind C-p
        unbind C-n

        # Setup clipboard binding keys
        unbind p
        bind -N "Paste the most recent paste buffer" p paste-buffer
        bind -N "Go back to previous window" P previous-window

        # Tmux-copycat functionality
        # https://github.com/tmux-plugins/tmux-copycat/issues/148#issuecomment-997929971
        bind -N "Copy selection" -T copy-mode-vi y send -X copy-selection-no-clear
        bind -N "Search backwards" / copy-mode \; send ?
        # Somewhat tmux-copycat select url functionality (requires 3.1+)
        bind -N "Select URL" C-u copy-mode \; send -X search-backward "(https?://|git@|git://|ssh://|ftp://|file:///)[[:alnum:]?=%/_.:,;~@!#$&()*+-]*"

        # Navigate panes using Alt-arrow without prefix
        bind -N "Switch pane, left" -n M-Left select-pane -L
        bind -N "Switch pane, right" -n M-Right select-pane -R
        bind -N "Switch pane, up" -n M-Up select-pane -U
        bind -N "Switch pane, down" -n M-Down select-pane -D

        # Join pane bindings
        bind -N "Join panes horizitonally" = choose-window 'join-pane -h -s "%%"'
        bind -N "Join panes vertically" + choose-window 'join-pane -s "%%"'

        # Split pane bindings
        unbind '"'
        unbind %
        bind-key -N "Split panes horizontally" "\\" split-window -h -c "#{pane_current_path}"
        bind-key -N "Split panes horizontally, full window length" "|" split-window -fh -c "#{pane_current_path}"
        bind-key -N "Split panes vertically" "-" split-window -v -c "#{pane_current_path}"
        bind-key -N "Split panes vertically, full window length" "_" split-window -fv -c "#{pane_current_path}"

        # Manage Session/Window
        bind -N "Switch to next window" -r ">" swap-window -d -t +1
        bind -N "Switch to previous window" -r "<" swap-window -d -t -1
        bind -N "Create new window" c new-window -c "#{pane_current_path}"
        bind -N "Create new session" C-c new-session
        bind -N "Toggle between windows" Space last-window
        bind -N "Toggle between current and previous session" C-Space switch-client -l
        bind -N "Jump to marked session" \` switch-client -t'{marked}'
        unbind &
        ${if cfg.disableConfirmationPrompt then ''
          bind -N "Kill the active pane" x kill-pane
          bind -N "Kill the current window" X kill-window
          bind -N "Kill the current session" C-x kill-session
        '' else ''
          bind -N "Kill the current window" X confirm-before -p "kill-window #W? (y/n)" kill-window
          bind -N "Kill the current session" C-x confirm-before -p "kill-session #W? (y/n)" kill-session
        ''}

        #Example
        #bind -N "Example note" h split-window -h "vim ~/scratch/notes.md"
        # -------------------------------------------------------------------------------------
      '';
      plugins = with pkgs.tmuxPlugins; [
        sensible
        {
          plugin = yank;
          extraConfig = ''
            # Enable Mouse support for tmux-yank
            set -g @yank_with_mouse on
          '';
        }
        open
        fuzzback
        extrakto
        (lib.mkIf (config.programs.fzf.enable) tmux-fzf)
        {
          plugin = nova;
          extraConfig = ''
            # -- statusline -----------------------------------------------------------------
            set -g @nova-nerdfonts true
            set -g @nova-nerdfonts-left 
            set -g @nova-nerdfonts-right 
            set -g @nova-rows 0

            # Colors
            set -gw window-status-current-style bold
            set -g "@nova-status-style-bg" "${c.base02}"
            set -g "@nova-status-style-fg" "${c.base05}"
            set -g "@nova-status-style-active-bg" "${c.base0D}"
            set -g "@nova-status-style-active-fg" "${c.base00}"

            #set -g "@nova-pane-active-border-style" "${c.base09}"
            #set -g "@nova-pane-border-style" "${c.base00}"

            # Declare Status
            #set -g @nova-segment-prefix "#{?client_prefix,Ω,ω}"
            # From https://github.com/o0th/tmux-nova/issues/33#issuecomment-1509927098
            set -g @nova-segment-action-prefix "#{?client_prefix,PREFIX,}#{?#{==:#{pane_mode},copy-mode}, COPY,}#{?#{==:#{pane_mode},view-mode}, VIEW,󰻀}"
            set -g @nova-segment-action-prefix-colors "${c.base0F} ${c.base00}"

            set -g @nova-pane "#I [#W]"

            #set -g @nova-segment-whoami "#(whoami)@#h"
            #set -g @nova-segment-whoami-colors "$light_purple $white"

            set -g @nova-pane "#I#{?pane_in_mode, #{pane_mode},} [#W]"

            # Declare system info
            set -g @nova-segment-battery "#{battery_icon_status} #{battery_percentage}"
            set -g @nova-segment-battery-colors "${c.base0E} ${c.base00}"
            #set -g @batt_icon_status_charging '↑'
            #set -g @batt_icon_status_discharging '↓'

            set -g @nova-segment-cpu "CPU #{cpu_percentage}"
            set -g @nova-segment-cpu-colors "${c.base09} ${c.base00}"

            set -g @nova-segment-ram "RAM #{ram_percentage}"
            set -g @nova-segment-ram-colors "${c.base0F} ${c.base00}"

            set -g @nova-segment-time "#(date +'%a %m/%d ${
              if cfg.clock24 then "%H:%M" else "%I:%M %p"
            }') #(date +%Z)"
            set -g @nova-segment-time-colors "${c.base03} ${c.base05}"

            set -g @nova-segments-0-left "action-prefix"
            set -g @nova-segments-0-right "battery cpu ram time"
          '';
        }
        cpu
        battery
      ];
    };
  };
}
