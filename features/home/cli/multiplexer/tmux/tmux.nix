{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.tmux;
  clipboardPkg =
    if osConfig.features.useWayland then
      "${lib.getExe' pkgs.wl-clipboard "wl-copy"}"
    else
      "${lib.getExe pkgs.xsel} -b";
in
{
  programs.fzf.tmux.enableShellIntegration = true;

  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    customPaneNavigationAndResize = true;
    baseIndex = 1;
    historyLimit = 50000;
    keyMode = "vi";
    focusEvents = true;
    mouse = true;
    escapeTime = 0;
    shortcut = "a";
    terminal = "tmux-256color";
    resizeAmount = 15;
    tmuxp.enable = true;
    sensibleOnTop = false; # Disable tmux-sensible plugin
    #newSession = true;
    #secureSocket = false;
    #which-key.enable = true;
  };

  programs.tmux.plugins = with pkgs.tmuxPlugins; [
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
    ${
      if osConfig.features.desktop != null then
        ''
          set -s set-clipboard external
          set -g copy-command "${clipboardPkg}"
        ''
      else
        "set -s set-clipboard on"
    }
    set -g set-titles on
    set -g set-titles-string "#{session_name} / #{window_name} / #(pwd)"
    set -g allow-passthrough on
    set -ga update-environment TERM
    set -ga update-environment TERM_PROGRAM
    set -g status-right-length 100

    # enable sixel support
    set -as terminal-features 'contour:sixel'

    # enable full RGB support
    set -ga terminal-overrides ",tmux*:RGB:Tc"
    set -ga terminal-overrides ",xterm*:RGB:Tc"

    # pane numbers, line messages duration and status line updates
    set -g display-panes-time 800 # slightly longer pane indicators display time
    set -g display-time 2000 # increase tmux messages display duration from 750ms to 2s
    set -g status-interval 5 # Refresh left and right statusbars more often, from every 15s to 5s

    # monitor for terminal activity changes, and manage how the alerts are displayed
    set -g monitor-activity on
    set -g visual-activity both

    setw -g automatic-rename on
    # renumber windows
    set -g renumber-windows on

    # change status bar position
    set -g status-position bottom
    # -------------------------------------------------------------------------------------


    # -- keybindings -----------------------------------------------------------------
    # reload config file (change file location to your the tmux.conf you want to use)
    bind -N "Reload configuration" r source-file ${config.xdg.configHome}/tmux/tmux.conf \; display "Sourced ${config.xdg.configHome}/tmux/tmux.conf!"

    # setup clipboard binding keys
    #unbind p
    #bind -N "Paste the most recent paste buffer" p paste-buffer

    # tmux-copycat functionality
    # https://github.com/tmux-plugins/tmux-copycat/issues/148#issuecomment-997929971
    bind -N "Copy selection" -T copy-mode-vi y send -X copy-selection-no-clear
    bind -N "Search backwards" / copy-mode \; send ?
    # Somewhat tmux-copycat select url functionality (requires 3.1+)
    bind -N "Select URL" C-u copy-mode \; send -X search-backward "(https?://|git@|git://|ssh://|ftp://|file:///)[[:alnum:]?=%/_.:,;~@!#$&()*+-]*"

    # window Navigation
    # unbind n and p, since we can use C-p and C-n for navigating windows
    #unbind n
    #unbind p
    # easier and faster switching between next/prev window
    bind C-p previous-window
    bind C-n next-window

    # join pane bindings
    bind -N "Join panes horizitonally" = choose-window 'join-pane -h -s "%%"'
    bind -N "Join panes vertically" + choose-window 'join-pane -s "%%"'

    # split pane bindings
    # unbind " and %, these are kinda unreasonable imo
    unbind '"'
    unbind %
    bind -N "Split panes horizontally" \\ split-window -h -c "#{pane_current_path}"
    bind -N "Split panes horizontally, full window length" | split-window -fh -c "#{pane_current_path}"
    bind -N "Split panes vertically" - split-window -v -c "#{pane_current_path}"
    bind -N "Split panes vertically, full window length" _ split-window -fv -c "#{pane_current_path}"

    # manage Session/Window
    bind -N "Create new window" c new-window -c "#{pane_current_path}"
    bind -N "Create new session" C-c new-session
    bind -N "Toggle between current and previous session" C-Space switch-client -l
    bind -N "Jump to marked session" \` switch-client -t'{marked}'
    # unbind old kill window keybind.. easier to remember the new one
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
          bind -N "Kill the current session" C-x confirm-before -p "kill-session #S? (y/n)" kill-session
        ''
    }

    # popup shell
    bind -n M-a display-popup -h 75% -w 75% -T ' +#S ' -E ${lib.getExe pkgs.tmux-popup}
    # support detaching from nested session with the same shortcut
    bind -T popup M-a detach
    bind -T popup M-[ copy-mode
    # break popup session into parent session as a new window
    bind -T popup M-! run 'tmux move-window -a -t $TMUX_PARENT_SESSION:{next}'
    # hide all popup sessions
    bind -n M-s choose-tree -Zs -f '#{?#{m:_popup_*,#S},0,1}' -O name

    # example
    # bind -N "Example note" h split-window -h "vim ~/scratch/notes.md"
    # -------------------------------------------------------------------------------------
  '';
}
