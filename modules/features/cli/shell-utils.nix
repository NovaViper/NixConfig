{
  config,
  lib,
  pkgs,
  ...
}:
lib.utilMods.mkModule config "shell-utils" {
  home.packages = with pkgs;
    [
      # Fancy utilities
      timer # Cooler timer in terminal
      tldr # better man pages
      entr # run commands when files change!
      procs # Better ps
      ventoy-full # bootable USB solution
      dust # Better du and df
      libnotify
    ]
    ++ lib.optionals (lib.conds.isWayland config) [wl-clipboard wl-clipboard-x11]
    ++ lib.optionals ((lib.conds.isX11 config) && (!lib.conds.isWayland config)) [
      xclip
      xsel
      xdotool
      xorg.xwininfo
      xorg.xprop
    ];

  # Custom colors for ls, grep and more
  hm.programs.dircolors.enable = true;

  # smart cd command, inspired by z and autojump
  hm.programs.zoxide.enable = true;

  # Shell extension to load and unload environment variables depending on the current directory.
  hm.programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    #config = {};
    stdlib = ''export DIRENV_ACTIVE=1'';
  };

  # Much better ls replacement
  hm.programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
    extraOptions = ["--color=always" "--group-directories-first" "--classify"];
  };

  # Fancy 'find' replacement
  hm.programs.fd = {
    enable = true;
    hidden = true;
    ignores = [".git/" "*.bak"];
  };

  # Fuzzy finder
  hm.programs.fzf = {
    enable = true;
    # Alt-C command options
    changeDirWidgetOptions = ["--preview 'eza --tree --color=always {} | head -200'"];
    # Ctrl-T command options
    fileWidgetOptions = ["--bind 'ctrl-/:change-preview-window(down|hidden|)'"];
    # Ctrl-R command options
    historyWidgetOptions = ["--sort" "--exact"];
  };
}
