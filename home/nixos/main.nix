{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
{
  imports = myLib.utils.importFeatures [
    ### Applications
    "apps/browsers/floorp"
    #"apps/nvim"
    "apps/ghostty"

    ### Shell
    "cli/shell/fish"

    ### Terminal Utils
    "cli/utils"
    "cli/git"
    "cli/oh-my-posh"
    "cli/multiplexer/tmux"
    "cli/atuin"

    #### Deco
    "cli/fastfetch"
    "cli/cava"
  ];

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
