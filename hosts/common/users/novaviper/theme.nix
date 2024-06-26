{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  stylix = {
    enable = true;
    autoEnable = true;
    image = "${inputs.wallpapers}/purple-mountains-ai.png";
    #base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
    override = {
      scheme = "BetterDracula";
      base00 = "282A36"; # Previously: "282936"
      #base01 = "3A3C4E"; # Unchanged
      base02 = "44475A"; # Previously: "4d4f68"
      base03 = "6272A4"; # Previously: "626483"
      #base04 = "62D6E8"; # Unchanged
      base05 = "F8F8F2"; # Previously: "e9e9f4"
      #base06 = "F1F2F8"; # Unchanged
      #base07 = "F7F7FB"; # Unchanged
      base08 = "FF5555"; # Previously: "ea51b2"
      base09 = "FFB86C"; # Previously: "B45BCF"
      base0A = "F1FA8C"; # Previously: "00f769"
      base0B = "50FA7B"; # Previously: "ebff87"
      base0C = "8BE9FD"; # Previously: "a1efe4"
      base0D = "BD93F9"; # Previously: "62d6e8"
      base0E = "FF79C6"; # Previously: "b45bcf"
      #base0F = "00F769"; # Unchanged
    };
    polarity = "dark";
    cursor = {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors-white";
      size = 24;
    };
    fonts = rec {
      sansSerif = {
        package = pkgs.nerdfonts;
        name = "NotoSans Nerd Font";
      };
      serif = sansSerif;
      monospace = {
        package = pkgs.nerdfonts;
        name = "0xProto Nerd Font Mono";
      };
      emoji = {
        package = pkgs.nerdfonts;
        name = "0xProto Nerd Font Mono";
      };
      sizes = {
        applications = 10;
        desktop = 10;
        popups = 10;
        terminal = 11;
      };
    };
    opacity = {
      applications = 1.0;
      desktop = 1.0;
      popups = 1.0;
      terminal = 1.0;
    };
  };
}
