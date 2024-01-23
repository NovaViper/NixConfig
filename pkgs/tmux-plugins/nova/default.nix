{ tmuxPlugins, fetchFromGitHub }:

tmuxPlugins.mkTmuxPlugin {
  pluginName = "tmux-nova";
  rtpFilePath = "nova.tmux";
  version = "1.1.0";
  src = fetchFromGitHub {
    owner = "o0th";
    repo = "tmux-nova";
    rev = "c827cd1d8fac4a86766d535a47d7174715d1b18c";
    hash = "sha256-qpviRordzZSqVzzK56rM1uHux7Ejfq2rxmTVCHfYV54=";
  };
}
