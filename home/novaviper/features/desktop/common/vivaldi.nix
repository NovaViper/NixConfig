{ config, lib, pkgs, ... }:

{
  xdg = {
    # Setup file associations
    mimeApps = {
      associations = {
        added = {
          "application/xhtml+xml" = "vivaldi.desktop";
          #"text/htmlh" = [ "vivaldi.desktop" ];
        };
        removed = {
          # Force vivaldi to open xhtml+xml files
          "application/xhtml+xml" = [ "emacsclient.desktop" "writer.desktop" ];
          #"text/htmlh" = [ "emacsclient.desktop" "writer.desktop" ];
        };
      };
      defaultApplications = {
        "application/xhtml+xml" = [ "vivaldi.desktop" ];
        "text/html" = [ "vivaldi.desktop" ];
        "text/xml" = [ "vivaldi.desktop" ];
        #"text/htmlh" = [ "vivaldi.desktop" ];
        "x-scheme-handler/http" = [ "vivaldi.desktop" ];
        "x-scheme-handler/https" = [ "vivaldi.desktop" ];
      };
    };
    # Makes Plasma Browser Integration work properly
    configFile."vivaldi/NativeMessagingHosts/org.kde.plasma.browser_integration.json".source =
      "${pkgs.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";
  };

  programs.vivaldi = {
    enable = true;
    dictionaries = with pkgs; [ hunspellDictsChromium.en_US ];
    commandLineArgs = [
      "--force-dark-mode"
      "--enable-force-dark"
      "--enable-features=WebUIDarkMode"
    ];
    extensions = [
      # Bypass Paywalls Clean
      {
        id = "lkbebcjgcmobigpeffafkodonchffocl";
        updateUrl =
          "https://gitlab.com/magnolia1234/bypass-paywalls-chrome-clean/-/raw/master/updates.xml";
      }
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # UBlock Origin
      { id = "gebbhagfogifgggkldgodflihgfeippi"; } # Return Dislikes
      { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # Sponsor Block
      { id = "oboonakemofpalcgghocfoadofidjkkk"; } # KeepassXC
      { id = "ponfpcnoihfmfllpaingbgckeeldkhle"; } # Enhancer for YouTube
      { id = "fonfeflegdnbhkfefemcgbdokiinjilg"; } # Chat Replay
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark Reader
      { id = "hmgpakheknboplhmlicfkkgjipfabmhp"; } # Pay
      { id = "bmnlcjabgnpnenekpadlanbbkooimhnj"; } # Honey
      { id = "cimiefiiaegbelhefglklhhakcgmhkai"; } # Plasma Browser Integration
      { id = "fkagelmloambgokoeokbpihmgpkbgbfm"; } # Indie Wiki Buddy
      { id = "clngdbkpkpeebahjckkjfobafhncgmne"; } # Stylus
      { id = "nenlahapcbofgnanklpelkaejcehkggg"; } # Save Now
    ];
  };
}
