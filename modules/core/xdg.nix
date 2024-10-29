{
  config,
  lib,
  ...
}: {
  environment.sessionVariables = {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    ANDROID_USER_HOME = "$XDG_DATA_HOME/android";
    CUDA_CACHE_PATH = "$XDG_CACHE_HOME/nv";
    TLDR_CACHE_DIR = "$XDG_CACHE_HOME/tldr";
  };
}
