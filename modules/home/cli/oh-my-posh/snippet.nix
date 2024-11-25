{
  config,
  lib,
  ...
}: {
  # Credit to Frestein for the original code that this is taken from
  # https://github.com/JanDeDobbeleer/oh-my-posh/issues/5438#issuecomment-2488593826
  programs.zsh.initExtra = lib.mkIf config.modules.oh-my-posh.enable (lib.mkBefore ''
    # OMP zsh-vi-mode integration
    _omp_redraw-prompt() {
      local precmd
      for precmd in "''${precmd_functions[@]}"; do
        "$precmd"
      done
      zle && zle reset-prompt
    }

    export POSH_VI_MODE="$(printf '\u276F')"

    function zvm_after_select_vi_mode() {
      case $ZVM_MODE in
      $ZVM_MODE_NORMAL)
        POSH_VI_MODE="$(printf '\u276E')"
        ;;
      $ZVM_MODE_INSERT)
        POSH_VI_MODE="$(printf '\u276F')"
        ;;
      $ZVM_MODE_VISUAL)
        POSH_VI_MODE="$(printf '\u2164')"
        ;;
      $ZVM_MODE_VISUAL_LINE)
        POSH_VI_MODE="$(printf '\u2164')"
        ;;
      $ZVM_MODE_REPLACE)
        POSH_VI_MODE="$(printf '\u25B6')"
        ;;
      esac
      _omp_redraw-prompt
    }
  '');
}
