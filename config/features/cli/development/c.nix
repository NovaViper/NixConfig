{ pkgs, ... }:
{
  hm.home.packages = with pkgs; [
    # :editor format
    clang-tools
    # :tools lsp
    omnisharp-roslyn
    gcc
  ];
}
