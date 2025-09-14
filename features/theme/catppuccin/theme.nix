{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  hm-config = config.hm;
  c = config.lib.stylix.colors.withHashtag;
  f = config.stylix.fonts;
  flavor = "mocha";
  accent = "mauve";
  chromeIdentifiers = {
    frappe = "olhelnoplefjdmncknfphenjclimckaf";
    latte = "jhjnalhegpceacdhbplhnakmkdliaddd";
    macchiato = "cmpdlhmnmjhihmcfnigoememnffkimlk";
    mocha = "bkkmolkhemgaeaeggcmfbghljjjoofoh";
  };
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
  hm.home.packages = with pkgs; [
    # (catppuccin.override {
    #   inherit accent;
    #   variant = flavor;
    # })
    (catppuccin-kde.override {
      flavour = lib.singleton flavor;
      accents = lib.singleton accent;
    })
    (papirus-icon-theme.override {
      color = "violet";
    })
  ];

  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = lib.mkForce "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    #image = "${inputs.wallpapers}/purple-mountains-ai.png";
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
  hm.stylix.targets = lib.mkForce {
    # Enable 256 colors for kitty
    kitty.variant256Colors = true;
    # Causes some mismatched colors with Dracula-tmux theme
    tmux.enable = false;
    # Disable stylix's KDE module, very broken currently
    kde.enable = false;
    # Using the doom-emacs theme
    emacs.enable = false;
    # Enable rainbow mode for cava
    cava.rainbow.enable = true;

    # Firefox + dervatives
    firefox = {
      colorTheme.enable = true;
      profileNames = [ "${hm-config.home.username}" ];
    };
    floorp = {
      colorTheme.enable = true;
      profileNames = [ "${hm-config.home.username}" ];
    };
  };

  services.displayManager.sddm.theme = "sddm-astronaut-theme";
  environment.systemPackages = lib.singleton sddm-astro;
  services.displayManager.sddm.extraPackages = lib.singleton sddm-astro;

  hm.programs.brave.extensions = lib.singleton { id = chromeIdentifiers.${flavor}; };

  hm.programs.plasma =
    let
      workspace = {
        lookAndFeel = "org.kde.breezedark.desktop";
        iconTheme = "Papirus-Dark";
        colorScheme = "Catppuccin${lib.toSentenceCase flavor + lib.toSentenceCase accent}";
        #splashScreen = "";
        wallpaperSlideShow = {
          path = [ "${inputs.wallpapers}/" ];
          interval = 300;
        };
      };
    in
    {
      overrideConfig = true;
      inherit workspace;
      kscreenlocker.appearance.wallpaperSlideShow = workspace.wallpaperSlideShow;
    };
}
