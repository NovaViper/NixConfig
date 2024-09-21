{
  outputs,
  config,
  pkgs,
  ...
}:
outputs.lib.mkModule config "c" {
  home.packages = with pkgs; [
    # :editor format
    clang-tools
    # :tools lsp
    omnisharp-roslyn
    gcc
  ];
}
