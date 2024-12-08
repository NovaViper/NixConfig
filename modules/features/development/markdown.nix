{
  config,
  myLib,
  pkgs,
  ...
}:
myLib.utilMods.mkModule config "markdown" {
  home.packages = with pkgs; [
    # :lang markdown
    proselint
    pandoc
    grip
  ];
}
