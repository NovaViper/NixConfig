{ pkgs, ... }:
{
  hm.home.packages = with pkgs; [
    # :lang markdown
    proselint
    pandoc
    grip
  ];
}
