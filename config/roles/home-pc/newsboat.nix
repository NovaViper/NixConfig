_:
let
  withTag =
    tag: feed:
    feed
    // {
      tags = (feed.tags or [ ]) ++ [ tag ];
    };

  redditFeed = withTag "reddit";
  securityFeed = withTag "security";

in
{
  hm.programs.newsboat = {
    enable = true;
    autoReload = true;
    autoFetchArticles.enable = true;
    autoVacuum.enable = true;
  };
  hm.programs.newsboat.urls = [
    (redditFeed {
      title = "NixOS Reddit";
      url = "https://www.reddit.com/r/NixOS/new/.rss";
      tags = [
        "nixos"
      ];
    })
    (redditFeed {
      title = "Unixporn Reddit";
      url = "https://www.reddit.com/r/unixporn/new/.rss";
      tags = [
        "unixporn"
        "ui"
        "decor"
      ];
    })
    # Supply Chain Monitoring
    (securityFeed {
      title = "The Hackers News";
      url = "https://feeds.feedburner.com/TheHackersNews";
    })
    (securityFeed {
      title = "The Bleeping Computer";
      url = "https://www.bleepingcomputer.com/feed/";
    })
    (securityFeed {
      title = "Socket.dev";
      url = "https://socket.dev/api/blog/feed.atom";
    })
    (securityFeed {
      title = "NixOS Security Annoucements";
      url = "https://discourse.nixos.org/c/announcements/security/56.rss";
      tags = [ "nixos" ];
    })
  ];
}
