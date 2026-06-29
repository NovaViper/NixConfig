{ pkgs, ... }:
{
  hm.home.packages = with pkgs; [
    # :editor format
    stylua
    # :tools lsp :lang lua
    lua-language-server
  ];
}
