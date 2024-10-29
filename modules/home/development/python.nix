{
  config,
  lib,
  pkgs,
  ...
}:
lib.utilMods.mkModule config "python" {
  programs.pyenv.enable = true;

  home.sessionVariables.PYENV_ROOT = "${config.xdg.dataHome}/pyenv";
  home.sessionPath = ["${config.home.sessionVariables.PYENV_ROOT}/bin"];

  home.packages = with pkgs; [
    # :lang python, debugger, formatter
    (python312.withPackages (ps: with ps; [debugpy pyflakes isort pytest black pip pipx]))
    pyright
    pipenv
  ];
}
