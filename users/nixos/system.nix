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
    "programs/browser/floorp"
    #"programs/nvim"
    "programs/ghostty"

    ### Shell
    "cli/shell/zsh"

    ### Terminal Utils
    "cli/utilities"
    "cli/oh-my-posh"
    "cli/deco"
    "cli/multiplexer/tmux"
    "cli/atuin"
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
