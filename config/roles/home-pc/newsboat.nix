_: {
  hm.programs.newsboat = {
    enable = true;
    autoReload = true;
    autoFetchArticles.enable = true;
    autoVacuum.enable = true;
  };
  hm.programs.newsboat.urls = [
    {
      title = "NixOS Reddit";
      url = "https://www.reddit.com/r/NixOS/new/.rss";
      tags = [
        "nixos-reddit"
        "nr"
      ];
    }
    {
      title = "Unixporn Reddit";
      tags = [
        "unixporn"
        "unix"
      ];
      url = "https://www.reddit.com/r/unixporn/new/.rss";
    }
    # Supply Chain Monitoring
    {
      title = "The Hackers News";
      url = "https://feeds.feedburner.com/TheHackersNews";
      tags = [ ];
    }
    {
      title = "The Bleeping Computer";
      url = "https://www.bleepingcomputer.com/feed/";
      tags = [ ];
    }
    {
      title = "Socket.dev";
      url = "https://socket.dev/api/blog/feed.atom";
      tags = [ ];
    }
  ];
}
