{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  c = config.lib.stylix.colors.withHashtag;
  f = config.stylix.fonts;
  sddm-astro = pkgs.sddm-astronaut.override {
    themeConfig = {
      # [General]
      CustomBackground = true;
      Background = "${inputs.wallpapers}/purple-mountains-ai.png";
      DimBackgroundImage = "0.0";

      # [Blur Settings]
      FullBlur = false;
      PartialBlur = true;
      BlurRadius = 80;

      # [Design Customizations]
      ## Form Customizations
      HaveFormBackground = true;
      FormPosition = "left";

      Font = f.sansSerif.name;
      FontSize = f.sizes.applications;

      ## Colors
      MainColor = c.base05;
      AccentColor = c.base0F;
      # Change password placeholder colors
      placeholderColor = c.base0F;
      IconColor = c.base05;
      # Make form use a darker color
      BackgroundColor = c.base00;

      # [Locale]
      HourFormat = "\"hh:mm A\"";
      DateFormat = "\"dddd, MMMM d, yyyy\"";

      # [Interface Behavior]
      HideVirtualKeyboard = "false";
      HideSystemButtons = "false";
      HideLoginButton = "false";
      #ForceHideVirtualKeyboardButton = "true";
    };
  };
in
{
  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = lib.mkForce "${pkgs.base16-schemes}/share/themes/dracula.yaml";
    #image = "${inputs.wallpapers}/purple-mountains-ai.png";
    override = {
      scheme = "BetterDracula";
      base00 = "282a36";
      base01 = "363447";
      base02 = "44475a";
      base03 = "6272a4";
      base04 = "9ea8c7";
      base05 = "f8f8f2";
      base06 = "f0f1f4";
      base07 = "ffffff";
      base08 = "ff5555";
      base09 = "ffb86c";
      base0A = "f1fa8c";
      base0B = "50fa7b";
      base0C = "8be9fd";
      base0D = "80bfff";
      base0E = "ff79c6";
      base0F = "bd93f9";
    };
    cursor = {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors-white";
      size = 24;
    };
    fonts =
      let
        sansSerif = {
          package = pkgs.nerd-fonts.noto;
          name = "NotoSans Nerd Font";
        };
        serif = sansSerif;
        monospace = {
          package = pkgs.nerd-fonts._0xproto;
          name = "0xProto Nerd Font";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
        sizes = {
          applications = 10;
          desktop = 10;
          popups = 10;
          terminal = 11;
        };
      in
      {
        inherit
          sansSerif
          serif
          monospace
          emoji
          sizes
          ;
      };
    opacity = {
      applications = 1.0;
      desktop = 1.0;
      popups = 1.0;
      terminal = 1.0;
    };
  };

  services.displayManager.sddm.theme = "sddm-astronaut-theme";
  environment.systemPackages = lib.singleton sddm-astro;
  services.displayManager.sddm.extraPackages = lib.singleton sddm-astro;
}
