{ lib, ... }:
{
  # Credit to Frestein for the original code that this is taken from
  # https://github.com/JanDeDobbeleer/oh-my-posh/issues/5438#issuecomment-2488593826
  hm.programs.zsh.initContent = lib.mkBefore ''
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
  '';

  hm.programs.fish = {
    shellInit =
      lib.mkOrder 1001 # fish
        ''
          # Load function to make oh-my-posh detect the bind variable and update cursor based on its value
          rerender_on_bind_mode_change
          # Load function to integrate oh-my-posh with fish's directory history functionality
          rerender_on_dir_change
        '';
    functions = {
      # Change bind variable based on current mode and make oh-my-posh redraw itself
      rerender_on_bind_mode_change = {
        description = "Change bind variable based on current mode and make oh-my-posh redraw itself";
        onVariable = "fish_bind_mode";
        body = # fish
          ''
            if test "$fish_bind_mode" != paste -a "$fish_bind_mode" != "$FISH__BIND_MODE"
                 set -gx FISH__BIND_MODE $fish_bind_mode
                 omp_repaint_prompt
             end
          '';
      };

      # Mask the `fish_default_mode_prompt` prompt to prevent it from echoing the current mode
      fish_default_mode_prompt = {
        description = "Display vi prompt mode";
        body = "# This function is masked and does nothing";
      };

      # Integrate with Alt+(leftarrow) and Alt+(rightarrow)
      rerender_on_dir_change = {
        description = "Integrate with Alt+(leftarrow) and Alt+(rightarrow)";
        onVariable = "PWD";
        body = "omp_repaint_prompt";
      };
    };
  };
}
