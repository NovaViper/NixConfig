{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  home-manager.sharedModules = lib.singleton (
    hm:
    let
      hm-config = hm.config;
    in
    {
      stylix.targets = lib.mkForce {
        # Enable 256 colors for kitty
        kitty.variant256Colors = true;
        # Causes some mismatched colors with Dracula-tmux theme
        tmux.enable = false;
        # Disable stylix's KDE module, very broken currently
        kde.enable = false;
        # Using the doom-emacs theme
        emacs.enable = false;
        # Enable rainbow mode for cava
        cava.rainbow.enable = true;

        firefox = {
          colorTheme.enable = true;
          profileNames = [ "${hm-config.home.username}" ];
        };
      };

      home.packages = with pkgs; [
        dracula-theme
        (papirus-icon-theme.override {
          color = "violet";
        })
      ];

      programs.plasma =
        let
          workspace = {
            lookAndFeel = "org.kde.breezedark.desktop";
            iconTheme = "Papirus-Dark";
            colorScheme = "DraculaPurple";
            #splashScreen = "";
            wallpaperSlideShow = {
              path = [ "${inputs.wallpapers}/" ];
              interval = 300;
            };
          };
        in
        {
          overrideConfig = true;
          inherit workspace;
          kscreenlocker.appearance.wallpaperSlideShow = workspace.wallpaperSlideShow;
        };
      programs.tmux.plugins =
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
  );
}
