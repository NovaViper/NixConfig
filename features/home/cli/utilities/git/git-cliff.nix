_: {
  # Enable fancy git changelogs
  programs.git-cliff = {
    enable = true;

    settings = {
      header = "Changelog";
      trim = true;
    };
  };
}
