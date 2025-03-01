{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: let
  cfg = config.hm.programs.tmux;
  hm-config = config.hm;
in
  myLib.utilMods.mkModule config "tmux" {
    # Fixes issue where cava can't run under tmux
    home.shellAliases.cava = lib.mkIf config.modules.cava.enable "TERM=xterm-256color cava";

    hm.programs.fzf.tmux.enableShellIntegration = true;

    hm.programs.tmux = {
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
      #which-key.enable = true;
    };

    hm.programs.tmux.extraConfig = ''
      # -- more settings ---------------------------------------------------------------
      set -s set-clipboard on
      set -g set-titles on
      set -g set-titles-string "#S / #W / #(pwd)"
      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM

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
      bind -N "Reload configuration" r source-file ${hm-config.xdg.configHome}/tmux/tmux.conf \; display "Reloaded!"

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

      # Join pane bindings
      bind -N "Join panes horizitonally" = choose-window 'join-pane -h -s "%%"'
      bind -N "Join panes vertically" + choose-window 'join-pane -s "%%"'

      # Split pane bindings
      unbind '"'
      unbind %
      unbind n
      unbind p
      bind -N "Split panes horizontally" \\ split-window -h -c "#{pane_current_path}"
      bind -N "Split panes horizontally, full window length" | split-window -fh -c "#{pane_current_path}"
      bind -N "Split panes vertically" - split-window -v -c "#{pane_current_path}"
      bind -N "Split panes vertically, full window length" _ split-window -fv -c "#{pane_current_path}"

      # Manage Session/Window
      bind -N "Switch to next window" > next-window
      bind -N "Switch to previous window" < previous-window
      bind -N "Create new window" c new-window -c "#{pane_current_path}"
      bind -N "Create new session" C-c new-session
      bind -N "Toggle between current and previous session" C-Space switch-client -l
      bind -N "Jump to marked session" \` switch-client -t'{marked}'
      unbind &
      ${
        if cfg.disableConfirmationPrompt
        then ''
          bind -N "Kill the active pane" x kill-pane
          bind -N "Kill the current window" X kill-window
          bind -N "Kill the current session" C-x kill-session
        ''
        else ''
          bind -N "Kill the current window" X confirm-before -p "kill-window #W? (y/n)" kill-window
          bind -N "Kill the current session" C-x confirm-before -p "kill-session #W? (y/n)" kill-session
        ''
      }

      #Example
      #bind -N "Example note" h split-window -h "vim ~/scratch/notes.md"
      # -------------------------------------------------------------------------------------
    '';

    hm.programs.tmux.plugins = with pkgs.tmuxPlugins; [
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
      (lib.mkIf hm-config.programs.fzf.enable tmux-fzf)
      {
        plugin = dracula;
        extraConfig = ''
          # Theme settings
          ## Statusbar options
          ### Enable window flags
          set -g @dracula-show-flags true

          ### Hide empty plugins
          set -g @dracula-show-empty-plugins false

          ## Powerline settings
          ### Show powerline symbols
          set -g @dracula-show-powerline true
          set -g @dracula-left-icon-padding 0

          ### Show edge icons
          set -g @dracula-show-edge-icons false

          # Left icon settings
          set -g @dracula-show-left-icon "#h | #S"

          # Theme Plugins
          set -g @dracula-plugins "ssh-session battery cpu-usage ram-usage time"

          ## SSH Session settings
          set -g @dracula-show-ssh-only-when-connected true

          ## Battery Settings
          set -g @dracula-battery-label false
          set -g @dracula-show-battery-status true

          ## CPU Usage Settings
          set -g @dracula-cpu-usage-label ""

          ## RAM Usage Settings
          set -g @dracula-ram-usage-label ""

          ## GPU Info Settings
          set -g @dracula-gpu-power-label "󰢮"
          set -g @dracula-gpu-usage-label "󰢮"
          set -g @dracula-gpu-vram-label "󰢮"
          set -g @dracula-gpu-usage-colors "red white"
        '';
      }
    ];
  }
