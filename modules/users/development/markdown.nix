{
  outputs,
  config,
  pkgs,
  ...
}:
outputs.lib.mkModule config "markdown" {
  home.packages = with pkgs; [
    # :lang markdown
    proselint
    pandoc
    grip
  ];
}
