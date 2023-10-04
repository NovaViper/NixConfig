{ config, lib, pkgs, ... }:

{
  programs.vivaldi = {
    enable = true;
    package = pkgs.vivaldi;
    #dictionaries = with pkgs; [ hunspellDictsChromium.en_US ];
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
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # Ublock origin
      { id = "gebbhagfogifgggkldgodflihgfeippi"; } # Return Dislikes
      { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # Sponsor Block
      { id = "oboonakemofpalcgghocfoadofidjkkk"; } # KeepassXC
      { id = "ponfpcnoihfmfllpaingbgckeeldkhle"; } # Enhancer for YouTube
      { id = "fonfeflegdnbhkfefemcgbdokiinjilg"; } # Chat replay
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark Reader
      { id = "hmgpakheknboplhmlicfkkgjipfabmhp"; } # Pay
      { id = "bmnlcjabgnpnenekpadlanbbkooimhnj"; } # Honey
      { id = "cimiefiiaegbelhefglklhhakcgmhkai"; } # Plasma Browser Integration
    ];
  };

  # Makes Plasma Browser Integration work properly
  xdg.configFile."vivaldi/NativeMessagingHosts/org.kde.plasma.browser_integration.json".source =
    "${pkgs.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";

  /* home.persistence = {
       "/persist/home/novaviper".directories = [ ".config/vivaldi" ];
     };
  */
}
