{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
let
  hm-config = config.hm;
in
{
  hm.programs.zsh.initContent = lib.mkMerge [
    # Place before everything (except for zprof)
    (lib.mkOrder 450 ''
      # If not running interactively, don't do anything
      [[ $- != *i* ]] && return
    '')

    # Place where other setopts are declared in home-manager
    (lib.mkOrder 900 (
      ''
        setopt BEEP # Enable terminal bell
        setopt CORRECT # Enable autocorrect
        setopt completealiases # Autcomplete aliases
        autoload -U colors && colors # Enable colors

        # Check if sudo-command-line function is available
        if typeset -f sudo-command-line > /dev/null; then
          zle -N sudo-command-line
          bindkey "^B" sudo-command-line
          bindkey -M vicmd '^B' sudo-command-line
        fi
      ''
      + (lib.optionalString hm-config.programs.pyenv.enable ''
        ### Pyenv command
        if command -v pyenv 1>/dev/null 2>&1; then
          eval "$(pyenv init -)"
        fi
      '')
    ))

    # Z Style Customizations
    (lib.mkOrder 2000 (
      ''
        # set descriptions format to enable group support
        zstyle ':completion:*:descriptions' format '[%d]'

        # set list-colors to enable filename colorizing
        zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

        # make directory list first
        zstyle ':completion:*' list-dirs-first true

        # don't complete unavailable commands.
        zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
      ''
      + (lib.optionalString hm-config.programs.fzf.enable ''
        # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
        zstyle ':completion:*' menu no

        zstyle ':fzf-tab:*' fzf-flags \
        --exact \
        --multi \
        ${
          if myLib.utils.useStylix hm-config then
            with hm-config.lib.stylix.colors.withHashtag;
            ''--color=fg:"${base06}",bg:"${base00}",preview-fg:"${base06}",preview-bg:"${base00}",hl:"${base08}",fg+:"${base00}",bg+:"${base0B}",gutter:"${base0B}",hl+:"${base00}",info:"${base0C}",border:"${base03}",prompt:"${base0C}",pointer:"${base00}",marker:"${base0E}",spinner:"${base0C}",header:"${base0C}"''
          else
            ""
        }

        # switch group using `<` and `>`
        zstyle ':fzf-tab:*' switch-group '<' '>'

        # trigger continuous trigger with space key
        zstyle ':fzf-tab:*' continuous-trigger 'space'

        # bind tab key to accept event
        zstyle ':fzf-tab:*' fzf-bindings 'tab:accept'

        # accept and run suggestion with enter key
        zstyle ':fzf-tab:*' accept-line enter

        #### FZF-TAB SUGGESTION ADDITIONS ####
        # Command completion preview
        zstyle ':fzf-tab:complete:-command-:*' fzf-preview \
          '(out=$(tldr --color always "$word") 2>/dev/null && echo $out) || (out=$(MANWIDTH=$FZF_PREVIEW_COLUMNS man "$word") 2>/dev/null && echo $out) || (out=$(which "$word") && echo $out) || echo "''${(P)word}"'

        # preview environment vars
        zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview \
        'echo ''${(P)word}'

        # give a preview of commandline arguments when completing `kill`
        zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
        zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
          '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
        zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap

        ### Systemctl
        zstyle ':fzf-tab:complete:systemctl-cat:*' fzf-preview 'SYSTEMD_COLORS=false systemctl cat -- $word | bat -lini'
        zstyle ':fzf-tab:complete:systemctl-help:*' fzf-preview 'systemctl help -- $word 2>/dev/null | bat -lhelp'
        zstyle ':fzf-tab:complete:(\\|*/|)systemctl-list-dependencies:*' fzf-preview \
          'case $group in
          unit)
            systemctl list-dependencies -- $word
            ;;
          esac'
        zstyle ':fzf-tab:complete:systemctl-show:*' fzf-preview 'systemctl show $word | bat -lini'
        zstyle ':fzf-tab:complete:systemctl-(status|(re|)start|(dis|en)able):*' fzf-preview 'systemctl status -- $word'


        # Show git
        # it is an example. you can change it
        zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
          'git diff $word | delta'
        zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
          'git log --color=always $word'
        zstyle ':fzf-tab:complete:git-help:*' fzf-preview \
          'git help $word | bat -plman --color=always'
        zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
          'case "$group" in
          "commit tag") git show --color=always $word ;;
          *) git show --color=always $word | delta ;;
          esac'
        zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
          'case "$group" in
          "modified file") git diff $word | delta ;;
          "recent commit object name") git show --color=always $word | delta ;;
          *) git log --color=always $word ;;
          esac'
      '')
      + (lib.optionalString hm-config.programs.eza.enable ''
        # preview directory's content with eza when completing cd or any path
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --group-directories-first --color=always $realpath'
        zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --group-directories-first --color=always $realpath'
        zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color=always $realpath'
      '')
      + (lib.optionalString hm-config.programs.tmux.enable ''
        # Enable fzf-tab integration with tmux
        zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
        zstyle ':fzf-tab:*' popup-min-size 100 20
      '')
    ))
  ];
}
