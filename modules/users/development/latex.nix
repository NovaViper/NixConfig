{
  outputs,
  config,
  pkgs,
  ...
}:
outputs.lib.mkModule config "latex" {
  home.packages = with pkgs; [
    # :editor format
    texlive.combined.scheme-medium #LaTex
  ];
}
