{ config, lib, pkgs, inputs, ... }:

let
  nvidia = if config.variables.machine.gpu == "nvidia" then true else false;
  machineScale = if config.variables.machine.buildType == "laptop" then
    ",highres,auto,0.75"
  else
    ",preferred,auto,auto";

in {
  imports = [
    #inputs.hyprland.homeManagerModules.default
    ./basic-binds.nix
    ./systemd-fixes.nix
    ./hyprbars.nix
  ];

  home.packages = with pkgs; [ hyprpicker networkmanagerapplet gtk3 ];
  home.sessionVariables = lib.mkMerge [
    # toolkit-specific scale
    (lib.mkIf (config.variables.machine.buildType == "laptop") {
      GDK_SCALE = "0.75";
    })
    ({ XCURSOR_SIZE = "32"; })
  ];

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };
    #settings = [];
    #style = '';
  };
  services.mako = {
    enable = true;
    anchor = "bottom-right";
    #backgroundColor = "#";
    #borderColor = "#";
    defaultTimeout = 10;
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      colors = {
        background = "282a36dd";
        text = "f8f8f2ff";
        match = "8be9fdff";
        selection-match = "8be9fdff";
        selection = "44475add";
        selection-text = "f8f8f2ff";
        border = "bd93f9ff";
      };
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    package = pkgs.inputs.hyprland.hyprland;
    enableNvidiaPatches = nvidia;
    settings = {
      # change monitor to high resolution, the last argument is the scale factor
      monitor = "${machineScale}";
      # unscale XWayland
      xwayland.force_zero_scaling = true;

      exec-once = [
        #"${pkgs.swaybg}/bin/swaybg -i ${config.wallpaper} --mode fill"
        "kdeconnect-indicator"
        "nm-applet --indicator"
        "hyprpaper"
        #"mako"
      ];

      # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";

        follow_mouse = "1";

        touchpad = { natural_scroll = false; };

        sensitivity = "0"; # -1.0 - 1.0, 0 means no modification.
      };

      general = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";

        layout = "dwindle";

        # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false;
      };

      decoration = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        rounding = 10;

        blur = {
          enabled = true;
          size = "3";
          passes = "1";
        };

        drop_shadow = "yes";
        shadow_range = "4";
        shadow_render_power = "3";
        "col.shadow" = "rgba(1a1a1aee)";
      };

      animations = {
        enabled = "yes";

        # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        pseudotile =
          "yes"; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = "yes"; # you probably want this
      };

      master = {
        # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
        new_is_master = true;
      };

      gestures = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        workspace_swipe = "on";
      };

      misc = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        force_default_wallpaper =
          "-1"; # Set to 0 to disable the anime mascot wallpapers
      };

      # See https://wiki.hyprland.org/Configuring/Keywords/ for more
      "$mod" = "SUPER";
      bind = let
        makoctl = "${config.services.mako.package}/bin/makoctl";
        pactl = "${pkgs.pulseaudio}/bin/pactl";
        notify-send = "${pkgs.libnotify}/bin/notify-send";
        fuzzel = "${config.programs.fuzzel.package}/bin/fuzzel";

        gtk-launch = "${pkgs.gtk3}/bin/gtk-launch";
        xdg-mime = "${pkgs.xdg-utils}/bin/xdg-mime";
        defaultApp = type: "${gtk-launch} $(${xdg-mime} query default ${type})";

        terminal = config.home.sessionVariables.TERMINAL;
        browser = defaultApp "x-scheme-handler/https";
        editor = defaultApp "text/plain";
      in [
        # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
        # Porgram bindings
        "$mod, Return, exec, ${terminal}"
        "$mod, e, exec, ${editor}"
        "$mod, v, exec, ${editor}"
        "$mod, b, exec, ${browser}"
        # Brightness control (only works if the system has lightd)
        ", XF86MonBrightnessUp, exec, light -A 10"
        ", XF86MonBrightnessDown, exec, light -U 10"
        # Volume
        ", XF86AudioRaiseVolume, exec, ${pactl} set-sink-volume @DEFAULT_SINK@ +5%"
        ", XF86AudioLowerVolume, exec, ${pactl} set-sink-volume @DEFAULT_SINK@ -5%"
        ", XF86AudioMute, exec, ${pactl} set-sink-mute @DEFAULT_SINK@ toggle"
        "SHIFT, XF86AudioMute, exec, ${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
        ", XF86AudioMicMute, exec, ${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
      ] ++
      # Notification manager
      (lib.optionals config.services.mako.enable
        [ "SUPER, w, exec, ${makoctl} dismiss" ]) ++

      # Launcher
      (lib.optionals config.programs.fuzzel.enable
        [ "SUPER, R, exec, ${fuzzel}" ]);
    };
    /* extraConfig''
       '';
    */
  };
}
