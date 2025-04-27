{
  config,
  lib,
  pkgs,
  ...
}: {
  # Source URLs were fetched via nurl
  programs.zsh.plugins = let
    omz = pkgs.fetchFromGitHub {
      owner = "ohmyzsh";
      repo = "ohmyzsh";
      rev = "959b6cf5eed78f108dc6e0f46b53816f5168dd3a";
      hash = "sha256-s5lvs1FKIQbOf83U5tzJ4VSV0rfdtVq1XIwKGWKTe04=";
    };
  in [
    # Docs https://github.com/jeffreytse/zsh-vi-mode#-usage
    {
      name = "zsh-vi-mode";
      #file = "zsh-vi-mode.plugin.zsh";
      src = pkgs.fetchFromGitHub {
        owner = "jeffreytse";
        repo = "zsh-vi-mode";
        rev = "f82c4c8f4b2bdd9c914653d8f21fbb32e7f2ea6c";
        hash = "sha256-CkU0qd0ba9QsPaI3rYCgalbRR5kWYWIa0Kn7L07aNUI=";
      };
    }

    # Fish-like Plugins
    {
      name = "autopair";
      #file = "autopair.plugin.zsh";
      src = pkgs.fetchFromGitHub {
        owner = "hlissner";
        repo = "zsh-autopair";
        rev = "449a7c3d095bc8f3d78cf37b9549f8bb4c383f3d";
        hash = "sha256-3zvOgIi+q7+sTXrT+r/4v98qjeiEL4Wh64rxBYnwJvQ=";
      };
    }
    {
      name = "zfunctions";
      #file = "zfunctions.plugin.zsh";
      src = pkgs.fetchFromGitHub {
        owner = "mattmc3";
        repo = "zfunctions";
        rev = "f94ce963bbd1155321dc4ac8d3f9cb94b773d9ba";
        hash = "sha256-8yOX4NvD0CvlRKXX9yEoxrN/d7MMGuDdIqNn55revr0=";
      };
    }
    {
      name = "fzf-tab";
      #file = "fzf-tab.plugin.zsh";
      src = pkgs.fetchFromGitHub {
        owner = "Aloxaf";
        repo = "fzf-tab";
        rev = "2abe1f2f1cbcb3d3c6b879d849d683de5688111f";
        hash = "sha256-zc9Sc1WQIbJ132hw73oiS1ExvxCRHagi6vMkCLd4ZhI=";
      };
    }
    {
      name = "auto-notify";
      #file = "auto-notify.plugin.zsh";
      src = pkgs.fetchFromGitHub {
        owner = "MichaelAquilina";
        repo = "zsh-auto-notify";
        rev = "cac2c193d9f227c99178ca7cf9e25152a36dd4ac";
        hash = "sha256-8r5RsyldJIzlWr9+G8lrkHvJ8KxTVO859M//wDnYOUY=";
      };
    }
    {
      name = "zsh-autosuggestions-abbreviations-strategy";
      #file = "zsh-autosuggestions-abbreviations-strategy.plugin.zsh";
      src = pkgs.fetchFromGitHub {
        owner = "olets";
        repo = "zsh-autosuggestions-abbreviations-strategy";
        rev = "8edbd1d52445d87172d355f8242082b1ec6c34e7";
        hash = "sha256-hYl9zplPpMoCsGmxX+NQtECZ5dHgQYqZfTGdV0vcZPk=";
      };
    }

    # Tmux integration
    (lib.mkIf config.programs.tmux.enable {
      name = "omz-tmux";
      file = "plugins/tmux/tmux.plugin.zsh";
      src = omz;
    })
    # Make ZLE use system clipboard
    {
      name = "zsh-system-clipboard";
      #file = "zsh-system-clipboard.plugin.zsh";
      src = pkgs.fetchFromGitHub {
        owner = "kutsan";
        repo = "zsh-system-clipboard";
        rev = "8b4229000d31e801e6458a3dfa2d60720c110d11";
        hash = "sha256-phsIdvuqcwtAVE1dtQyXcMgNdRMNY03/mIzsvHWPS1Y=";
      };
    }
  ];
}
