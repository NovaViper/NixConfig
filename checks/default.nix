{
  inputs,
  pkgs,
  ...
}: let
  git-hooks-in = inputs.git-hooks;
  checks-in = git-hooks-in.checks.${pkgs.system};
in {
  pre-commit-check = git-hooks-in.lib.${pkgs.system}.run {
    src = ../.;
    default_stages = ["pre-commit"];
    hooks = {
      # ------------- general -------------
      check-added-large-files.enable = true;
      check-case-conflicts.enable = true;
      check-executables-have-shebangs = {
        enable = true;
        excludes = [".*/zsh/functions/.*" ".+\.nix" ".+\.org" "flake.lock" ".gitignore"];
      };
      check-shebang-scripts-are-executable.enable = true;
      check-merge-conflicts.enable = true;
      detect-private-keys = {
        enable = true;
        excludes = ["atuin.nix"];
      };
      fix-byte-order-marker.enable = true;
      mixed-line-endings.enable = true;

      trim-trailing-whitespace = {
        enable = true;
        excludes = [".*/dotfiles/PrusaSlicer/.*" ".*/dotfiles/alvr/.*" ".*/dotfiles/zsh/.*" "flake.lock" ".+\.patch" ".+\.diff"];
      };

      forbid-submodules = {
        enable = true;
        name = "forbid submodules";
        description = "forbids any submodules in the repository";
        language = "fail";
        entry = "submodules are not allowed in this repository:";
        types = ["directory"];
      };

      destroyed-symlinks = {
        enable = true;
        name = "destroyed-symlinks";
        description = "detects symlinks which are changed to regular files with a content of a path which that symlink was pointing to.";
        package = checks-in.pre-commit-hooks;
        entry = "${checks-in.pre-commit-hooks}/bin/destroyed-symlinks";
        types = ["symlink"];
      };

      # ------------- nix -------------
      flake-checker.enable = true;
      alejandra.enable = true;

      /*
        deadnix = {
        enable = true;
        settings = {
          noLambdaArg = true;
          noLambdaPatternNames = true;
        };
      };
      */

      statix = {
        enable = true;
        settings = {
          config = "../statix.toml";
          ignore = [
            ".direnv"
            "**/hardware-configuration.nix"
          ];
        };
      };

      nil.enable = true;

      # ------------- shellscripts -------------
      shfmt = {
        enable = true;
        excludes = [".p10k.zsh"];
      };

      end-of-file-fixer = {
        enable = true;
        excludes = [".*/dotfiles/.*" "secrets/.*" "flake.lock"];
      };
    };
  };
}
