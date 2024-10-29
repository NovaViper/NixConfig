{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.modules.gaming;
  hm-config = config.hm;
in
  lib.utilMods.mkModule' config "gaming" {
    minecraft-server.enable = lib.mkEnableOption "Enable minecraft server configs";
    vr.enable = lib.mkEnableOption "Enable virual reality configs";
  } (lib.mkMerge [
    # Minecraft
    (lib.mkIf cfg.minecraft-server.enable {
      # Allow Minecraft server ports
      networking.firewall.allowedTCPPorts = [25565 24454];

      hm = {
        home.packages = with pkgs; [prismlauncher flite orca];

        programs.java.enable = true;

        home.shellAliases = {
          start-minecraft-server = "cd ~/Games/MinecraftServer-1.21.x/ && ./run.sh --nogui && cd || cd";
          start-minecraft-fabric-server = "cd ~/Games/MinecraftFabricServer-1.20.1/ && java -Xmx8G -jar ./fabric-server-mc.1.20.1-loader.0.15.7-launcher.1.0.0.jar nogui && cd || cd";
        };
      };
    })
    # VR
    (lib.mkIf cfg.vr.enable {
      environment.systemPackages = with pkgs; [
        android-tools
        android-udev-rules
        BeatSaberModManager
        helvum
      ];

      # Enable ALVR module on NixOS
      programs.alvr = {
        enable = true;
        openFirewall = true;
      };

      # Fixes issue with SteamVR not starting
      system.activationScripts.fixSteamVR = "${pkgs.libcap}/bin/setcap CAP_SYS_NICE+ep /home/${username}/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher";
      hm = {
        xdg.desktopEntries = {
          "BeatSaberModManager" = {
            name = "Beat Saber ModManager";
            genericName = "Game";
            exec = "BeatSaberModManager";
            icon = "${pkgs.BeatSaberModManager}/lib/BeatSaberModManager/Resources/Icons/Icon.ico";
            type = "Application";
            categories = ["Game"];
            startupNotify = true;
            comment = "Beat Saber ModManager is a mod manager for Beat Saber";
          };
        };
      };
    })
    # Common
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
      programs.gamemode = {
        enable = true;
        enableRenice = true;
        settings = {
          general = {
            softrealtime = "off";
            inhibit_screensaver = 1;
          };
          custom = {
            start = "''${pkgs.libnotify}/bin/notify-send 'GameMode started'";
            end = "''${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
          };
        };
      };

      programs.steam = {
        enable = true;
        package = pkgs.steam.override {
          extraEnv = {
            # Make Steam folder spawn in ~/.config instead of /home/USER
            HOME = "/home/${username}/.config";
          };
        };
        remotePlay.openFirewall = true;
      };

      # Enable Steam hardware compatibility
      hardware.steam-hardware.enable = true;

      # Fixes SteamLink/Remote play crashing
      environment = {
        systemPackages = with pkgs; [protontricks keyutils goverlay ludusavi libcanberra protonup-qt];
        sessionVariables.ICED_BACKEND = "tiny-skia";
      };

      xdg.mime = {
        defaultApplications."x-scheme-handler/steam" = "steam.desktop";
        addedAssociations."x-scheme-handler/steam" = "steam.desktop";
      };

      hm = {
        xdg = {
          userDirs.extraConfig.XDG_GAME_DIR = "${hm-config.home.homeDirectory}/Games";
          mimeApps = {
            defaultApplications."x-scheme-handler/steam" = "steam.desktop";
            associations.added."x-scheme-handler/steam" = "steam.desktop";
          };
        };

        programs.mangohud = {
          enable = true;
          settings = {
            ### From https://github.com/flightlessmango/MangoHud/blob/master/data/MangoHud.conf
            ### MangoHud configuration file
            ### Uncomment any options you wish to enable. Default options are left uncommented
            ### Use some_parameter=0 to disable a parameter (only works with on/off parameters)
            ### Everything below can be used / overridden with the environment variable MANGOHUD_CONFIG instead

            ################ INFORMATIONAL #################
            ## prints possible options on stdout
            # help = true;

            ################ PERFORMANCE #################

            ### Limit the application FPS. Comma-separated list of one or more FPS values (e.g. 0,30,60). 0 means unlimited (unless VSynced)
            # fps_limit = 0;

            ### early = wait before present, late = wait after present
            # fps_limit_method = "";

            ### VSync [0-3] 0 = adaptive; 1 = off; 2 = mailbox; 3 = on
            # vsync = -1;

            ### OpenGL VSync [0-N] 0 = off; >=1 = wait for N v-blanks, N > 1 acts as a FPS limiter (FPS = display refresh rate / N)
            # gl_vsync = -2;

            ### Mip-map LoD bias. Negative values will increase texture sharpness (and aliasing)
            ## Positive values will increase texture blurriness (-16 to 16)
            # picmip = -17;

            ### Anisotropic filtering level. Improves sharpness of textures viewed at an angle (0 to 16)
            # af = -1;

            ### Force bicubic filtering
            # bicubic = true;

            ### Force trilinear filtering
            # trilinear = true;

            ### Disable linear texture filtering. Makes textures look blocky
            # retro = true;

            ################### VISUAL ###################

            ### Legacy layout
            # legacy_layout = 0;

            ### pre defined presets
            # -1 = default
            #  0 = no display
            #  1 = fps only
            #  2 = horizontal view
            #  3 = extended
            #  4 = high detailed information
            # preset = -1;

            ### Enable most of the toggleable parameters (currently excludes `histogram`)
            # full = true;

            ### Show FPS only. ***Not meant to be used with other display params***
            # fps_only = true;

            ### Display custom centered text, useful for a header
            # custom_text_center = "";

            ### Display the current system time
            # time = true;

            ### Time formatting examples
            ## %H:%M
            ## [ %T %F ]
            ## %X # locally formatted time, because of limited glyph range, missing characters may show as '?' (e.g. Japanese)
            # time_format = "%T";

            ### Display MangoHud version
            # version = true;

            ### Display the current GPU information
            ## Note: gpu_mem_clock and gpu_mem_temp also need "vram" to be enabled
            gpu_stats = true;
            gpu_temp = true;
            # gpu_junction_temp = true;
            # gpu_core_clock = true;
            # gpu_mem_temp = true;
            # gpu_mem_clock = true;
            # gpu_power = true;
            # gpu_text = "";
            gpu_load_change = true;
            #gpu_load_value = [ "60" "90" ];
            #gpu_load_color = [ "39F900" "FDFD09" "B22222" ];
            ## GPU fan in rpm (only works on AMD GPUs)
            # gpu_fan = true;
            # gpu_voltage = true; # (only works on AMD GPUs)

            ### Display the current CPU information
            cpu_stats = true;
            cpu_temp = true;
            # cpu_power = true;
            # cpu_text = "";
            # cpu_mhz = true;
            cpu_load_change = true;
            #cpu_load_value = [ "60" "90" ];
            #cpu_load_color = [ "39F900" "FDFD09" "B22222" ];

            ### Display the current CPU load & frequency for each core
            # core_load = true;
            # core_load_change = true;

            ### Display IO read and write for the app (not system)
            # io_read = true;
            # io_write = true;

            ### Display system vram / ram / swap space usage
            vram = true;
            ram = true;
            # swap = true;

            ### Display per process memory usage
            ## Show resident memory and other types, if enabled
            # procmem = true;
            # procmem_shared = true;
            # procmem_virt = true;

            ### Display battery information
            # battery = true;
            # battery_icon = true;
            # gamepad_battery = true;
            # gamepad_battery_icon = true;
            # battery_watt = true;
            # battery_time = true;

            ### Display FPS and frametime
            fps = true;
            # fps_sampling_period = 500;
            # fps_color_change = true;
            # fps_value = ["30" "60"];
            # fps_color=["22222" "FDFD09" "39F900"];
            frametime = true;
            # frame_count = true;

            ### Display GPU throttling status based on Power, current, temp or "other"
            ## Only shows if throttling is currently happening
            throttling_status = true;

            ### Display miscellaneous information
            # engine_version = true;
            # engine_short_names = true;
            # gpu_name = true;
            # vulkan_driver = true;
            # wine = true;
            # exec_name = true;

            ### Display loaded MangoHud architecture
            # arch = true;

            ### Display the frametime line graph
            frame_timing = true;
            # histogram = true;

            ### Display GameMode / vkBasalt running status
            # gamemode = true;
            # vkbasalt = true;

            ### Gamescope related options
            ## Display the status of FSR (only works in gamescope)
            # fsr = true;
            ## Hides the sharpness info for the `fsr` option (only available in gamescope)
            # hide_fsr_sharpness = true;
            ## Shows the graph of gamescope app frametimes and latency (only on gamescope obviously)
            # debug = true;

            ### graphs displays one or more graphs that you chose
            ## seperated by ",", available graphs are
            ## gpu_load,cpu_load,gpu_core_clock,gpu_mem_clock,vram,ram,cpu_temp,gpu_temp
            # graphs = [""];

            ### mangoapp related options
            ## Enables mangoapp to be displayed above the Steam UI
            # mangoapp_steam = true;

            ### Steam Deck options
            ## Shows the Steam Deck fan rpm
            # fan = true;

            ### Display current FPS limit
            show_fps_limit = true;

            ### Display the current resolution
            # resolution = true;

            ### Display custom text
            # custom_text = "";
            ### Display output of Bash command in next column
            # exec = "";

            ### Display media player metadata
            # media_player = true;
            ## for example spotify
            # media_player_name = "";
            ## Format metadata, lines are delimited by ; (wip)
            ## example: {title};{artist};{album}
            ## example: Track:;{title};By:;{artist};From:;{album}
            # media_player_format = ["title" "artist" "album"];

            ### Change the hud font size
            # font_size = 24;
            # font_scale = 1.0;
            # font_size_text = 24;
            # font_scale_media_player = 0.55;
            # no_small_font = true;

            ### Change default font (set location to TTF/OTF file)
            ## Set font for the whole hud
            # font_file = "";

            ## Set font only for text like media player metadata
            # font_file_text = "";

            ## Set font glyph ranges. Defaults to Latin-only. Don't forget to set font_file/font_file_text to font that supports these
            ## Probably don't enable all at once because of memory usage and hardware limits concerns
            ## If you experience crashes or text is just squares, reduce glyph range or reduce font size
            # font_glyph_ranges = ["korean" "chinese" "chinese_simplified" "japanese" "cyrillic" "thai" "vietnamese" "latin_ext_a" "latin_ext_b"];

            ### Outline text
            text_outline = true;
            # text_outline_color = 000000;
            # text_outline_thickness = 1.5;

            ### Change the hud position
            # position = "top-left";

            ### Change the corner roundness
            # round_corners = 0;

            ### Remove margins around MangoHud
            # hud_no_margin = true;

            ### Display compact version of MangoHud
            # hud_compact = true;

            ### Display MangoHud in a horizontal position
            # horizontal = true;
            # horizontal_stretch = true;

            ### Disable / hide the hud by default
            # no_display = true;

            ### Hud position offset
            # offset_x = 0;
            # offset_y = 0;

            ### Hud dimensions
            # width = 0;
            # height = 140;
            # table_columns = 3;
            # cellpadding_y = -0.085;

            ### Hud transparency / alpha
            # background_alpha = 0.5;
            # alpha = 1.0;

            ### FCAT overlay
            ### This enables an FCAT overlay to perform frametime analysis on the final image stream.
            ### Enable the overlay
            # fcat = true;
            ### Set the width of the FCAT overlay.
            ### 24 is a performance optimization on AMD GPUs that should not have adverse effects on nVidia GPUs.
            ### A minimum of 20 pixels is recommended by nVidia.
            # fcat_overlay_width = 24;
            ### Set the screen edge, this can be useful for special displays that don't update from top edge to bottom. This goes from 0 (left side) to 3 (top edge), counter-clockwise.
            # fcat_screen_edge = 0;

            ### Color customization
            # text_color = "FFFFFF";
            # gpu_color = "2E9762";
            # cpu_color = "2E97CB";
            # vram_color = "AD64C1";
            # ram_color = "C26693";
            # engine_color = "EB5B5B";
            # io_color = "A491D3";
            # frametime_color = "00FF00";
            # background_color = "020202";
            # media_player_color = "FFFFFF";
            # wine_color = "EB5B5B";
            # battery_color = "FF9078";

            ### Specify GPU with PCI bus ID for AMDGPU and NVML stats
            ### Set to 'domain:bus:slot.function'
            # pci_dev = "0:0a:0.0";

            ### Blacklist
            # blacklist = "";

            ### Control over socket
            ### Enable and set socket name, '%p' is replaced with process id
            ## example: mangohud
            ## example: mangohud-%p
            # control = -1;

            ################ WORKAROUNDS #################
            ### Options starting with "gl_*" are for OpenGL
            ### Specify what to use for getting display size. Options are "viewport", "scissorbox" or disabled. Defaults to using glXQueryDrawable
            # gl_size_query = "viewport";

            ### (Re)bind given framebuffer before MangoHud gets drawn. Helps with Crusader Kings III
            # gl_bind_framebuffer = 0;

            ### Don't swap origin if using GL_UPPER_LEFT. Helps with Ryujinx
            # gl_dont_flip = 1;

            ################ INTERACTION #################

            ### Change toggle keybinds for the hud & logging
            toggle_hud = "Shift_R+F12";
            # toggle_hud_position = "Shift_R+F11";
            # toggle_fps_limit = "Shift_L+F1";
            toggle_logging = "Shift_L+F2";
            # reload_cfg = "Shift_L+F4";
            # upload_log = "Shift_L+F3";

            #################### LOG #####################
            ### Automatically start the log after X seconds
            # autostart_log = "";
            ### Set amount of time in seconds that the logging will run for
            # log_duration = "";
            ### Change the default log interval, 0 is default
            # log_interval = 0;
            ### Set location of the output files (required for logging)
            output_folder = "${hm-config.xdg.stateHome}/mangologs";
            ### Permit uploading logs directly to FlightlessMango.com
            ## set to 1 to enable
            # permit_upload = 0;
            ### Define a '+'-separated list of percentiles shown in the benchmark results
            ### Use "AVG" to get a mean average. Default percentiles are 97+AVG+1+0.1
            ## example: ['97', 'AVG', '1', '0.1']
            # benchmark_percentiles = ["97" "AVG"];
            ## Adds more headers and information such as versioning to the log. This format is not supported on flightlessmango.com (yet)
            # log_versioning = true;
            ## Enable automatic uploads of logs to flightlessmango.com
            # upload_logs = true;
          };
        };
      };
    }
  ])
