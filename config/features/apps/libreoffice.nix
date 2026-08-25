{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    libreoffice-qt-stable
    hunspell
    hunspellDicts.en_US
    hyphenDicts.en_US
  ];
}
