{
  programs.zsh = {
    enable = true;
    histFile = "$HOME/.config/zsh/.zsh_history";
    #    profileExtra = lib.optionalString (config.home.sessionPath != [ ]) ''
    #      export PATH="$PATH''${PATH:+:}${lib.concatStringsSep ":" config.home.sessionPath}"
    #    '';
  };

  # Get completion for system packages
  environment.pathsToLink = [ "/share/zsh" ];
}
