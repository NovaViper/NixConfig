{
  config,
  myLib,
  pkgs,
  ...
}:
myLib.utilMods.mkModule config "c" {
  home.packages = with pkgs; [
    # :editor format
    clang-tools
    # :tools lsp
    omnisharp-roslyn
    gcc
  ];
}
