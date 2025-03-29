{
  config,
  pkgs,
  ...
}: {
  hm.programs.pyenv.enable = true;

  hm.home.sessionVariables.PYENV_ROOT = "${config.hm.xdg.dataHome}/pyenv";

  hm.home.sessionPath = ["${config.hm.home.sessionVariables.PYENV_ROOT}/bin"];

  hm.home.packages = with pkgs; let
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
