{
  config,
  lib,
  pkgs,
  ...
}:
lib.utilMods.mkModule config "java" {
  programs.java.enable = true;

  home.sessionVariables.JDTLS_PATH = "${pkgs.jdt-language-server}/share/java";
  home.sessionPath = [
    "${config.home.sessionVariables.PYENV_ROOT}/bin"
  ];
  home.packages = with pkgs; [
    # :tools lsp
    java-language-server

    # :lang java
    jdt-language-server
  ];
}
