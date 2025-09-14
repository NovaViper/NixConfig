{ pkgs, ... }:
{
  hm.programs.java.enable = true;

  hm.home.sessionVariables.JDTLS_PATH = "${pkgs.jdt-language-server}/share/java";

  hm.home.packages = with pkgs; [
    # :tools lsp
    java-language-server

    # :lang java
    jdt-language-server
  ];
}
