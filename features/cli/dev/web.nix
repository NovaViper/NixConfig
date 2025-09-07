{ pkgs, ... }:
{
  hm.home.packages = with pkgs; [
    # :editor format
    html-tidy

    # :lang web
    stylelint
    jsbeautifier
  ];
}
