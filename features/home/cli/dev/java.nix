{ pkgs, ... }:
{
  programs.java.enable = true;

  home.sessionVariables.JDTLS_PATH = "${pkgs.jdt-language-server}/share/java";

  home.packages = with pkgs; [
    # :tools lsp
    java-language-server

    # :lang java
    jdt-language-server
  ];
}
