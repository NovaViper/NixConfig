{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    libreoffice-qt6-fresh
    hunspell
    hunspellDicts.en_US
    hyphenDicts.en_US
  ];
}
