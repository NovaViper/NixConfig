{
  config,
  myLib,
  pkgs,
  ...
}:
myLib.utilMods.mkModule config "python" {
  hm.programs.pyenv.enable = true;

  home.sessionVariables.PYENV_ROOT = "${config.hm.xdg.dataHome}/pyenv";

  home.sessionPath = ["${config.home.sessionVariables.PYENV_ROOT}/bin"];

  home.packages = with pkgs; let
    myPythonPackages = ps:
      with ps; [
        debugpy
        pyflakes
        isort
        pytest
        black
        pip
        pipx
      ];
  in [
    # :lang python, debugger, formatter
    (python312.withPackages myPythonPackages)
    pyright
    pipenv
  ];
}
