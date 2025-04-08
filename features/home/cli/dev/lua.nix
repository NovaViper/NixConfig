{pkgs, ...}: {
  hm.home.packages = with pkgs; [
    # :editor format
    nodePackages.lua-fmt
    # :tools lsp :lang lua
    lua-language-server
  ];
}
