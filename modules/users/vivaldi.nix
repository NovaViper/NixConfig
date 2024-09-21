{
  config,
  outputs,
  pkgs,
  ...
}:
outputs.lib.mkDesktopModule config "vivaldi" {
  xdg = {
    mimeApps = outputs.lib.mkIf (config.defaultBrowser == "vivaldi") rec {
      enable = true;
      defaultApplications = {
        "default-web-browser" = ["vivaldi.desktop"];
        "text/html" = ["vivaldi.desktop"];
        "x-scheme-handler/http" = ["vivaldi.desktop"];
        "x-scheme-handler/https" = ["vivaldi.desktop"];
        "x-scheme-handler/about" = ["vivaldi.desktop"];
        "x-scheme-handler/unknown" = ["vivaldi.desktop"];
        "application/xhtml+xml" = ["vivaldi.desktop"];
        "text/xml" = ["vivaldi.desktop"];
      };
      associations.added = defaultApplications;
    };

    # Makes Plasma Browser Integration work properly
    configFile."vivaldi/NativeMessagingHosts/org.kde.plasma.browser_integration.json".source = "${pkgs.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";
  };

  programs.vivaldi = {
    enable = true;
    dictionaries = with pkgs; [hunspellDictsChromium.en_US];
    extensions = [
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # UBlock Origin
      {id = "gebbhagfogifgggkldgodflihgfeippi";} # Return Dislikes
      {id = "mnjggcdmjocbbbhaepdhchncahnbgone";} # Sponsor Block
      {id = "oboonakemofpalcgghocfoadofidjkkk";} # KeepassXC
      {id = "ponfpcnoihfmfllpaingbgckeeldkhle";} # Enhancer for YouTube
      {id = "fonfeflegdnbhkfefemcgbdokiinjilg";} # Chat Replay
      {id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";} # Dark Reader
      {id = "hmgpakheknboplhmlicfkkgjipfabmhp";} # Pay
      {id = "bmnlcjabgnpnenekpadlanbbkooimhnj";} # Honey
      {id = "cimiefiiaegbelhefglklhhakcgmhkai";} # Plasma Browser Integration
      {id = "fkagelmloambgokoeokbpihmgpkbgbfm";} # Indie Wiki Buddy
      {id = "clngdbkpkpeebahjckkjfobafhncgmne";} # Stylus
      {id = "nenlahapcbofgnanklpelkaejcehkggg";} # Save Now
      {id = "jinjaccalgkegednnccohejagnlnfdag";} # Violetmonkey
    ];
  };
}
