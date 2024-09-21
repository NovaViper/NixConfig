{
  outputs,
  config,
  pkgs,
  ...
}:
outputs.lib.mkModule config "web" {
  home.packages = with pkgs; [
    # :editor format
    html-tidy

    # :lang web
    stylelint
    jsbeautifier
  ];
}
