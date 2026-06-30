{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
{
  imports = myLib.utils.importFeatures {
    apps = [
      "browsers/firefox"
      "ghostty"
    ];
    cli = [
      "shell/fish"
      "multiplexer/zellij"
      "utils"
      "git"
      "oh-my-posh"
      # Decorations
      "fastfetch"
      "cava"
    ];

  };

  hm.userVars = {
    defaultTerminal = "ghostty";
    defaultBrowser = "firefox";
  };

  hm.programs.zsh.initContent = lib.mkOrder 5000 ''
    # Create shell prompt
    if [ $(tput cols) -ge '75' ] || [ $(tput cols) -ge '100' ]; then
      ${lib.getExe pkgs.toilet} -f pagga "ISO MAGE" --metal
      ${lib.getExe pkgs.fastfetch}
    fi
  '';

  hm.programs.fish.functions.fish_greeting = # fish
    ''
      sleep 0.1 # Delay slightly to allow for tput to measure the panes
      set -l cols (tput cols)
      if test $cols -ge 75
          or test $cols -ge 100
        ${lib.getExe pkgs.toilet} -f pagga "ISO MAGE" --metal
        ${lib.getExe pkgs.fastfetch}
      end
    '';

  hm.programs.git.settings.user = {
    name = "";
    email = "";
  };
}
