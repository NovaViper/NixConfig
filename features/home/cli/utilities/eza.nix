_: {
  # Much better ls replacement
  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
    extraOptions = ["--color=always" "--group-directories-first" "--classify=always"];
  };
}
