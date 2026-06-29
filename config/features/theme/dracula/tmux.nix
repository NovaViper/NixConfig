{ pkgs, ... }:
{

  hm.programs.tmux.plugins =
    with pkgs.tmuxPlugins;
    lib.mkBefore [
      {
        plugin = dracula;
        extraConfig =
          # tmux
          ''
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
            set -g @dracula-show-left-icon "#h |#{?#{N/s:_popup_#S}, +, }#S"

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
