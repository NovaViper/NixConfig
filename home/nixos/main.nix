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
      "browsers/floorp"
      "ghostty"
    ];
    cli = [
      "shell/fish"
      "multiplexer/tmux"
      "utils"
      "git"
      "oh-my-posh"
      "atuin"
      # Decorations
      "fastfetch"
      "cava"
    ];

  };

  hm.userVars = {
    defaultTerminal = "ghostty";
    defaultBrowser = "floorp";
  };

  hm.programs.zsh.initContent = lib.mkOrder 5000 ''
    # Create shell prompt
    if [ $(tput cols) -ge '75' ] || [ $(tput cols) -ge '100' ]; then
      ${lib.getExe pkgs.toilet} -f pagga "ISO MAGE" --metal
      ${lib.getExe pkgs.fastfetch}
    fi
  '';

  hm.programs.git.settings.user = {
    name = "";
    email = "";
  };
}
