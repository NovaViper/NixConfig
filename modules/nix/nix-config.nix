{
  # Make sure the root user and users in the wheel group are trusted
  trusted-users = ["root" "@wheel"];

  # Make sure flakes is enabled
  experimental-features = ["nix-command" "flakes"];

  # Don't spam about the git repo being dirty
  warn-dirty = false;

  # Disable global flake registry
  #flake-registry = "";

  # Force XDG Base Directory paths for Nix path
  use-xdg-base-directories = true;

  # Reasonable defaults, see https://jackson.dev/post/nix-reasonable-defaults/
  connect-timeout = 5;
  log-lines = 25;
  min-free = 128000000; # 128MB
  max-free = 1000000000; # 1GB
}
