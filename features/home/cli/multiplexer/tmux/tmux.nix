{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.tmux;
in
{
  programs.fzf.tmux.enableShellIntegration = true;

  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    customPaneNavigationAndResize = true;
    baseIndex = 1;
    historyLimit = 5000;
    keyMode = "vi";
    mouse = true;
    #escapeTime = 0;
    shortcut = "a";
    terminal = "xterm-256color";
    resizeAmount = 15;
    tmuxp.enable = true;
    #newSession = true;
    #secureSocket = false;
    #which-key.enable = true;
  };

  programs.tmux.plugins = with pkgs.tmuxPlugins; [
    sensible
    weather
    battery
    cpu
    online-status
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
    (lib.mkIf config.programs.fzf.enable tmux-fzf)
  ];

  programs.tmux.extraConfig = ''
    # -- more settings ---------------------------------------------------------------
    set -s set-clipboard on
    set -g set-titles on
    set -g set-titles-string "#{session_name} / #{window_name} / #(pwd)"
    set -g allow-passthrough on
    set -ga update-environment TERM
    set -ga update-environment TERM_PROGRAM

    set-option -g status-right-length 100

    # Enable sixel support
    set -as terminal-features 'contour:sixel'

    # Enable full RGB support
    set -ga terminal-overrides ",xterm*:RGB:Tc"

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
      if cfg.disableConfirmationPrompt then
        ''
          bind -N "Kill the active pane" x kill-pane
          bind -N "Kill the current window" X kill-window
          bind -N "Kill the current session" C-x kill-session
        ''
      else
        ''
          bind -N "Kill the current window" X confirm-before -p "kill-window #W? (y/n)" kill-window
          bind -N "Kill the current session" C-x confirm-before -p "kill-session #W? (y/n)" kill-session
        ''
    }

    #Example
    #bind -N "Example note" h split-window -h "vim ~/scratch/notes.md"
    # -------------------------------------------------------------------------------------
  '';
}
