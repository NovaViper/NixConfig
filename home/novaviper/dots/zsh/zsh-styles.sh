zstyle ':completion:*:descriptions' format '[%d]' # set descriptions format to enable group support
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} # set list-colors to enable filename colorizing
zstyle ':fzf-tab:*' switch-group ',' '.' # switch group using `,` and `.`
zstyle ':fzf-tab:*' continuous-trigger 'space' # trigger continuous trigger with space key
zstyle ':fzf-tab:*' fzf-bindings 'tab:accept' # bind tab key to accept event
zstyle ':fzf-tab:*' accept-line enter # accept and run suggestion with enter key
zstyle ':completion:complete:*:options' sort false # disable sorting when completing any command
