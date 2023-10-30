{ config, pkgs, lib, ... }:

{
  xdg.configFile = {
    "zsh/.p10k.zsh".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.sessionVariables.FLAKE}/home/novaviper/dots/zsh/.p10k.zsh";
    "zsh/functions" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.sessionVariables.FLAKE}/home/novaviper/dots/zsh/functions";
      recursive = true;
    };
    "zsh/zsh-styles.sh".source = ../../dots/zsh/zsh-styles.sh;
    "zsh/manpages.zshrc".source = ../../dots/zsh/manpages.zshrc;
    #"zsh/zsh-functions.sh".source = ../../dots/zsh/zsh-functions.sh;
    "zsh/zsh-syntax-highlighting.sh".source =
      ../../dots/zsh/zsh-syntax-highlighting.sh;
  };

  home.packages = with pkgs; [ wl-clipboard wl-clipboard-x11 ];

  services.gpg-agent.enableZshIntegration = true;

  programs = {
    mcfly = {
      enable = true;
      enableZshIntegration = true;
      fuzzySearchFactor = 2;
      keyScheme = "vim";
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      colors = {
        fg = "#f8f8f2"; # foreground
        bg = "#282a36"; # background
        hl = "#bd93f9"; # purple
        "fg+" = "#f8f8f2"; # foreground
        "bg+" = "#44475a"; # current-line
        "hl+" = "#bd93f9"; # purple
        info = "#ffb86c"; # orange
        prompt = "#50fa7b"; # green
        pointer = "#ff79c6"; # pink
        marker = "#ff79c6"; # pink
        spinner = "#ffb86c"; # orange
        header = "#6272a4"; # comment
      };
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;
      dotDir = ".config/zsh";
      defaultKeymap = "viins";
      historySubstringSearch.enable = true;
      autocd = true;
      zsh-abbr = {
        enable = true;
        #abbreviations = { };
      };
      history = {
        expireDuplicatesFirst = true;
        extended = true;
        ignoreDups = true;
        path = "$HOME/.config/zsh/.zsh_history";
      };
      localVariables = {
        AUTO_NOTIFY_EXPIRE_TIME = 5000; # in miliseconds
        ZVM_CURSOR_STYLE_ENABLED = false;
        SPROMPT =
          "Correct $fg[red]%R$reset_color to $fg[green]%r$reset_color? [nyae] ";
        HISTTIMEFORMAT = "[%F %T] ";
        ZSH_AUTOSUGGEST_STRATEGY = [ "history" "completion" ];
        MANPAGER = "${pkgs.less}/bin/less -s -M +Gg";
      };
      initExtraFirst = ''
        # If not running interactively, don't do anything
        [[ $- != *i* ]] && return

        #if [ -z "$TMUX" ]; then
        #  ${pkgs.tmux}/bin/tmux attach >/dev/null 2>&1 || ${pkgs.tmuxp}/bin/tmuxp load ${config.xdg.configHome}/tmuxp/session.yaml >/dev/null 2>&1
        #  exit
        #fi
      '';

      initExtra = ''
        # Append extra variables
        AUTO_NOTIFY_IGNORE+=("yadm" "emacs")

        source "$ZDOTDIR/manpages.zshrc"
        source "$ZDOTDIR/.p10k.zsh"
        source "$ZDOTDIR/zsh-syntax-highlighting.sh"
        source "$ZDOTDIR/zsh-styles.sh"
        #source "$ZDOTDIR/zsh-functions.sh"
        setopt beep CORRECT # Enable terminal bell and autocorrect
        autoload -U colors && colors # Enable colors

        ### Pyenv command
        if command -v pyenv 1>/dev/null 2>&1; then
          eval "$(pyenv init -)"
        fi

        # Create shell prompt
        if [ $(tput cols) -ge '80' ] || [ $(tput cols) -ge '100' ]; then
          ${pkgs.dwt1-shell-color-scripts}/bin/colorscript exec square
          ${pkgs.toilet}/bin/toilet -f pagga "FOSS AND BEAUTIFUL" --metal
        fi
      '';

      shellAliases = {
        # Easy access to accessing Doom cli
        doom = "${config.home.sessionVariables.EMDOTDIR}/bin/doom";
        # Refresh Doom configurations and Reload Doom Emacs
        doom-config-reload =
          "${config.home.sessionVariables.EMDOTDIR}/bin/org-tangle ${config.home.sessionVariables.DOOMDIR}/config.org && ${config.home.sessionVariables.EMDOTDIR}/bin/doom sync && systemctl --user restart emacs";
        # Substitute Doom upgrade command to account for fixing the issue of org-tangle not working
        doom-upgrade = ''
          ${config.home.sessionVariables.EMDOTDIR}/bin/doom upgrade --force && sed -i -e "/'org-babel-tangle-collect-blocks/,+1d" ${config.home.sessionVariables.EMDOTDIR}/bin/org-tangle
        '';
        # Download Doom Emacs frameworks
        doom-download = ''
          git clone https://github.com/hlissner/doom-emacs.git ${config.home.sessionVariables.EMDOTDIR}
        '';
        # Run fix to make org-tangle module work again
        doom-fix = ''
          sed -i -e "/'org-babel-tangle-collect-blocks/,+1d" ${config.home.sessionVariables.EMDOTDIR}/bin/org-tangle
        '';
        # Create Emacs config.el from my Doom config.org
        doom-org-tangle =
          "${config.home.sessionVariables.EMDOTDIR}/bin/org-tangle ${config.home.sessionVariables.DOOMDIR}/config.org";
        # Easy Weather
        weather = "curl 'wttr.in/Baton+Rouge?u?format=3'";
        # Make gpg switch Yubikey
        gpg-switch-yubikey =
          ''gpg-connect-agent "scd serialno" "learn --force" /bye'';

        # Make gpg smartcard functionality work again
        #fix-gpg-smartcard =
        #"pkill gpg-agent && sudo systemctl restart pcscd.service && sudo systemctl restart pcscd.socket && gpg-connect-agent /bye";
        # Load PKCS11 keys into ssh-agent
        load-pkcs-key = "ssh-add -s ${pkgs.opensc}/lib/pkcs11/opensc-pkcs11.so";
        # Remove PKCS11 keys into ssh-agent
        remove-pkcs-key =
          "ssh-add -e ${pkgs.opensc}/lib/pkcs11/opensc-pkcs11.so";
        # Remove all identities
        remove-ssh-keys = "ssh-add -D";
        # List all SSH keys in the agent
        list-ssh-key = "ssh-add -L";
        # Make resident ssh keys import from Yubikey
        load-res-keys = "ssh-keygen -K";
        # Quickly start Minecraft server
        start-minecraft-server = lib.mkIf (config.programs.mangohud.enable)
          "cd ~/Games/MinecraftServer-1.20.1/ && ./run.sh --nogui && cd || cd";
      };
      antidote = {
        enable = true;
        useFriendlyNames = true;
        plugins = [
          # Prompts
          "romkatv/powerlevel10k"

          #Docs https://github.com/jeffreytse/zsh-vi-mode#-usage
          "jeffreytse/zsh-vi-mode"

          # Fish-like Plugins
          "mattmc3/zfunctions"
          "Aloxaf/fzf-tab"
          "MichaelAquilina/zsh-auto-notify"

          # Sudo escape
          "ohmyzsh/ohmyzsh path:lib"
          "ohmyzsh/ohmyzsh path:plugins/sudo"
          #"ohmyzsh/ohmyzsh path:plugins/tmux"

          # Nix stuff
          "chisui/zsh-nix-shell"

          # Make ZLE use system clipboard
          "kutsan/zsh-system-clipboard"
        ];
      };
      /* zplug = {
           enable = true;
           zplugHome = "${config.xdg.configHome}/zsh/zplug";
           plugins = [
             {
               name = "romkatv/powerlevel10k";
               tags = [ "as:theme" "depth:1" ];
             }
             #Docs https://github.com/jeffreytse/zsh-vi-mode#-usage
             { name = "jeffreytse/zsh-vi-mode"; }
             { name = "mattmc3/zfunctions"; }
             { name = "Aloxaf/fzf-tab"; }
             { name = "MichaelAquilina/zsh-auto-notify"; }
             {
               name = "plugins/sudo";
               tags = [ "from:oh-my-zsh" ];
             }
             {
               name = "plugins/tmux";
               tags = [ "from:oh-my-zsh" ];
             }
             { name = "chisui/zsh-nix-shell"; }
           ];
         };
      */
    };
    dircolors = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        #NORMAL = "00"; # no color code at all
        #FILE = "00"; # regular file: use no color at all
        RESET = "0"; # reset to "normal" color
        DIR = "01;38;2;189;147;249"; # directory
        LINK =
          "01;38;2;139;233;253"; # symbolic link.  (If you set this to 'target' instead of a
        # numerical value, the color is as for the file pointed to.)
        MULTIHARDLINK = "00"; # regular file with more than one link
        FIFO = "48;2;33;34;44;38;2;241;250;140"; # pipe
        SOCK = "01;38;2;255;121;198"; # socket
        DOOR = "01;38;2;255;121;198"; # door
        BLK = "48;2;33;34;44;38;2;241;250;140;01"; # block device driver
        CHR = "48;2;33;34;44;38;2;241;250;140;01"; # character device driver
        ORPHAN =
          "48;2;33;34;44;38;2;255;85;85;01"; # symlink to nonexistent file, or non-stat'able file ...
        MISSING = "00"; # ... and the files they point to
        SETUID = "38;2;248;248;242;48;2;255;85;85"; # file that is setuid (u+s)
        SETGID = "38;2;33;34;44;48;2;241;250;140"; # file that is setgid (g+s)
        CAPABILITY = "00"; # file with capability (very expensive to lookup)
        STICKY_OTHER_WRITABLE =
          "38;2;33;34;44;48;2;80;250;123"; # dir that is sticky and other-writable (+t,o+w)
        OTHER_WRITABLE =
          "38;2;189;147;249;48;2;80;250;123"; # dir that is other-writable (o+w) and not sticky
        STICKY =
          "38;2;248;248;242;48;2;189;147;249"; # dir with the sticky bit set (+t) and not other-writable

        # This is for files with execute permission:
        EXEC = "01;38;2;80;250;123";

        # archives or compressed (bright red)
        ".tar" = "01;38;2;255;85;85";
        ".tgz" = "01;38;2;255;85;85";
        ".arc" = "01;38;2;255;85;85";
        ".arj" = "01;38;2;255;85;85";
        ".taz" = "01;38;2;255;85;85";
        ".lha" = "01;38;2;255;85;85";
        ".lz4" = "01;38;2;255;85;85";
        ".lzh" = "01;38;2;255;85;85";
        ".lzma" = "01;38;2;255;85;85";
        ".tlz" = "01;38;2;255;85;85";
        ".txz" = "01;38;2;255;85;85";
        ".tzo" = "01;38;2;255;85;85";
        ".t7z" = "01;38;2;255;85;85";
        ".zip" = "01;38;2;255;85;85";
        ".z" = " 01;38;2;255;85;85";
        ".dz" = " 01;38;2;255;85;85";
        ".gz" = "01;38;2;255;85;85";
        ".lrz" = "01;38;2;255;85;85";
        ".lz" = "01;38;2;255;85;85";
        ".lzo" = "01;38;2;255;85;85";
        ".xz" = "01;38;2;255;85;85";
        ".zst" = "01;38;2;255;85;85";
        ".tzst" = "01;38;2;255;85;85";
        ".bz2" = "01;38;2;255;85;85";
        ".bz" = "01;38;2;255;85;85";
        ".tbz" = "01;38;2;255;85;85";
        ".tbz2" = "01;38;2;255;85;85";
        ".tz" = "01;38;2;255;85;85";
        ".deb" = "01;38;2;255;85;85";
        ".rpm" = "01;38;2;255;85;85";
        ".jar" = "01;38;2;255;85;85";
        ".war" = "01;38;2;255;85;85";
        ".ear" = "01;38;2;255;85;85";
        ".sar" = "01;38;2;255;85;85";
        ".rar" = "01;38;2;255;85;85";
        ".alz" = "01;38;2;255;85;85";
        ".ace" = "01;38;2;255;85;85";
        ".zoo" = "01;38;2;255;85;85";
        ".cpio" = "01;38;2;255;85;85";
        ".7z" = "01;38;2;255;85;85";
        ".rz" = "01;38;2;255;85;85";
        ".cab" = "01;38;2;255;85;85";
        ".wim" = "01;38;2;255;85;85";
        ".swm" = "01;38;2;255;85;85";
        ".dwm" = "01;38;2;255;85;85";
        ".esd" = "01;38;2;255;85;85";

        # image formats
        ".avif" = "01;38;2;255;121;198";
        ".jpg" = "01;38;2;255;121;198";
        ".jpeg" = "01;38;2;255;121;198";
        ".mjpg" = "01;38;2;255;121;198";
        ".mjpeg" = "01;38;2;255;121;198";
        ".gif" = "01;38;2;255;121;198";
        ".bmp" = "01;38;2;255;121;198";
        ".pbm" = "01;38;2;255;121;198";
        ".pgm" = "01;38;2;255;121;198";
        ".ppm" = "01;38;2;255;121;198";
        ".tga" = "01;38;2;255;121;198";
        ".xbm" = "01;38;2;255;121;198";
        ".xpm" = "01;38;2;255;121;198";
        ".tif" = "01;38;2;255;121;198";
        ".tiff" = "01;38;2;255;121;198";
        ".png" = "01;38;2;255;121;198";
        ".svg" = "01;38;2;255;121;198";
        ".svgz" = "01;38;2;255;121;198";
        ".mng" = "01;38;2;255;121;198";
        ".pcx" = "01;38;2;255;121;198";
        ".mov" = "01;38;2;255;121;198";
        ".mpg" = "01;38;2;255;121;198";
        ".mpeg" = "01;38;2;255;121;198";
        ".m2v" = "01;38;2;255;121;198";
        ".mkv" = "01;38;2;255;121;198";
        ".webm" = "01;38;2;255;121;198";
        ".webp" = "01;38;2;255;121;198";
        ".ogm" = "01;38;2;255;121;198";
        ".mp4" = "01;38;2;255;121;198";
        ".m4v" = "01;38;2;255;121;198";
        ".mp4v" = "01;38;2;255;121;198";
        ".vob" = "01;38;2;255;121;198";
        ".qt " = "01;38;2;255;121;198";
        ".nuv" = "01;38;2;255;121;198";
        ".wmv" = "01;38;2;255;121;198";
        ".asf" = "01;38;2;255;121;198";
        ".rm " = "01;38;2;255;121;198";
        ".rmvb" = "01;38;2;255;121;198";
        ".flc" = "01;38;2;255;121;198";
        ".avi" = "01;38;2;255;121;198";
        ".fli" = "01;38;2;255;121;198";
        ".flv" = "01;38;2;255;121;198";
        ".gl" = "01;38;2;255;121;198";
        ".dl" = "01;38;2;255;121;198";
        ".xcf" = "01;38;2;255;121;198";
        ".xwd" = "01;38;2;255;121;198";
        ".yuv" = "01;38;2;255;121;198";
        ".cgm" = "01;38;2;255;121;198";
        ".emf" = "01;38;2;255;121;198";

        # https://wiki.xiph.org/MIME_Types_and_File_Extensions
        ".ogv" = "01;38;2;255;121;198";
        ".ogx" = "01;38;2;255;121;198";

        # audio formats
        ".aac" = "00;38;2;139;233;253";
        ".au" = "00;38;2;139;233;253";
        ".flac" = "00;38;2;139;233;253";
        ".m4a" = "00;38;2;139;233;253";
        ".mid" = "00;38;2;139;233;253";
        ".midi" = "00;38;2;139;233;253";
        ".mka" = "00;38;2;139;233;253";
        ".mp3" = "00;38;2;139;233;253";
        ".mpc" = "00;38;2;139;233;253";
        ".ogg" = "00;38;2;139;233;253";
        ".ra" = "00;38;2;139;233;253";
        ".wav" = "00;38;2;139;233;253";

        # https://wiki.xiph.org/MIME_Types_and_File_Extensions
        ".oga" = "00;38;2;139;233;253";
        ".opus" = "00;38;2;139;233;253";
        ".spx" = "00;38;2;139;233;253";
        ".xspf" = "00;38;2;139;233;253";

        # backup files
        "*~" = "00;38;2;98;114;164";
        "*#" = "00;38;2;98;114;164";
        ".bak" = "00;38;2;98;114;164";
        ".crdownload" = "00;38;2;98;114;164";
        ".dpkg-dist" = "00;38;2;98;114;164";
        ".dpkg-new" = "00;38;2;98;114;164";
        ".dpkg-old" = "00;38;2;98;114;164";
        ".dpkg-tmp" = "00;38;2;98;114;164";
        ".old" = "00;38;2;98;114;164";
        ".orig" = "00;38;2;98;114;164";
        ".part" = "00;38;2;98;114;164";
        ".rej" = "00;38;2;98;114;164";
        ".rpmnew" = "00;38;2;98;114;164";
        ".rpmorig" = "00;38;2;98;114;164";
        ".rpmsave" = "00;38;2;98;114;164";
        ".swp" = "00;38;2;98;114;164";
        ".tmp" = "00;38;2;98;114;164";
        ".ucf-dist" = "00;38;2;98;114;164";
        ".ucf-new" = "00;38;2;98;114;164";
        ".ucf-old" = "00;38;2;98;114;164";
      };
    };
  };
}
