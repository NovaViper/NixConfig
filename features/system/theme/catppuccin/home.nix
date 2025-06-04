{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  flavor = "mocha";
  accent = "mauve";
  mkSegment =
    {
      segColor,
      textColor ? "thm_bg",
      segSymbol,
      segSymbolEnd ? "",
      text,
    }:
    "#[fg=#{@${segColor}}]${segSymbol}#[bg=#{@${textColor}},reverse]${text}#[bg=#{@${segColor}},none]${segSymbolEnd}";

  mkRightSegment =
    {
      segColor,
      textColor ? "thm_bg",
      text,
    }:
    mkSegment {
      inherit segColor textColor;
      text = " ${text} ";
      segSymbol = "";
      segSymbolEnd = "";
    };
  mkRightEndSegment =
    {
      segColor,
      textColor ? "thm_bg",
      text,
    }:
    mkSegment {
      inherit segColor textColor;
      text = " ${text}";
      segSymbol = "";
      segSymbolEnd = "█";
    };
in
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

        # Firefox + dervatives
        firefox = {
          colorTheme.enable = true;
          profileNames = [ "${hm-config.home.username}" ];
        };
        floorp = {
          colorTheme.enable = true;
          profileNames = [ "${hm-config.home.username}" ];
        };
      };

      home.packages = with pkgs; [
        # (catppuccin.override {
        #   inherit accent;
        #   variant = flavor;
        # })
        (catppuccin-kde.override {
          flavour = lib.singleton flavor;
          accents = lib.singleton accent;
        })
        (papirus-icon-theme.override {
          color = "violet";
        })
      ];

      programs.plasma =
        let
          workspace = {
            lookAndFeel = "org.kde.breezedark.desktop";
            iconTheme = "Papirus-Dark";
            colorScheme = "Catppuccin${lib.toSentenceCase flavor + lib.toSentenceCase accent}";
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
            plugin = catppuccin;
            extraConfig =
              # tmux
              ''
                # Theme settings
                ## Top-level options
                set -g window-status-separator "" # Must be disabled for more consistent look
                set -g @catppuccin_flavor "${flavor}"
                set -g @catppuccin_window_flags "icon"
                set -g @catppuccin_window_number_position "left"
                set -g @catppuccin_date_time_text "󰭦 %Y-%m-%d  󰅐 %H:%M"

                ## Window Customization
                ## Powerline seperators
                set -g @catppuccin_window_status_style "custom"
                set -g @catppuccin_window_right_separator "#[fg=#{@_ctp_status_bg},reverse]#[none]"
                set -g @catppuccin_window_left_separator "#[fg=#{@_ctp_status_bg}]#[none]"
                set -g @catppuccin_window_middle_separator ""
                #set -g @catppuccin_window_middle_separator "#[fg=#{@catppuccin_window_number_color},bg=#{@catppuccin_window_text_color}]"
                #set -g @catppuccin_window_current_middle_separator "#[bg=#{@catppuccin_window_current_number_color}]"

                ### Text
                set -g @catppuccin_window_number " #[fg=#{@thm_fg}]#I:"
                set -g @catppuccin_window_current_number " #I:"
                set -g @catppuccin_window_text "#W"
                set -g @catppuccin_window_current_text "#[fg=#{@thm_bg}]#W"

                ### Colors
                set -g @catppuccin_window_text_color "#{@thm_surface_0}"
                set -g @catppuccin_window_number_color "#{@thm_surface_0}"
                set -g @catppuccin_window_current_text_color "#{@thm_mauve}"
                set -g @catppuccin_window_current_number_color "#{@thm_mauve}"

                ## Left Statusline
                set -g status-left-length 100
                set -g status-left ""
                set -ag status-left "#[bg=#{@thm_bg},fg=#{?client_prefix,#{@thm_red},#{?#{==:#{pane_mode},copy-mode},#{@thm_yellow},#{@thm_lavender}}}]█#[reverse] #{?#{N/s:_popup_#S}, +, }#S #[noreverse]#[none]"

                ## Right Status
                set -g status-right-length 100
                set -g status-right ""
                set -ga status-right "#[bg=#{@thm_bg}]#{?#{==:#{online_status},✔},#[fg=#{@thm_yellow}]#[reverse] 󰖩 on #[bg=#{@thm_yellow}]#[none],#[fg=#{@thm_red}]#[reverse] 󰖪 off #[bg=#{@thm_red}]#[none]}"
                set -ga status-right "${
                  mkRightSegment {
                    segColor = "thm_teal";
                    text = "#{battery_icon} #{battery_percentage}";
                  }
                }"
                set -ga status-right "${
                  mkRightSegment {
                    segColor = "thm_mauve";
                    text = " #{cpu_percentage}";
                  }
                }"
                set -ga status-right "${
                  mkRightSegment {
                    segColor = "thm_blue";
                    text = " #{ram_percentage}";
                  }
                }"
                set -ga status-right "${
                  mkRightEndSegment {
                    segColor = "thm_green";
                    text = "#{E:@catppuccin_date_time_text}";
                  }
                }"
              '';
          }
        ];
    }
  );
}
