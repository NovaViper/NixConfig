{pkgs, ...}: {
  home.packages = with pkgs; [
    # :editor format
    texlive.combined.scheme-medium #LaTex
  ];
}
