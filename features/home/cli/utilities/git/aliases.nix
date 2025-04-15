{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.git.aliases = {
    p = "pull --ff-only";
    ff = "merge --ff-only";
    graph = "log --decorate --oneline --graph";
    pushall = "!git remote | xargs -L1 git push --all";
    add-nowhitespace = "!git diff -U0 -w --no-color | git apply --cached --ignore-whitespace --unidiff-zero -";

    #Llakala's special sauce
    amend = "commit --amend --no-edit"; # amend an existing commit's content based on what's in staging
    reword = "commit --amend --only"; # reword an existing commit's message, without changing the content
    force = "push --force-with-lease --force-if-includes";

    brb = "stash push --staged"; # Leave a branch temporarily. Staged files are stashed, while unstaged will travel with us to the other branch
    imback = "stash pop";

    unstage = "restore --staged"; # Unstage changes
    goback = "restore"; # Undo unstaged changes

    # Patch versions of add, unstage, and goback
    hire = "add --patch";
    fire = "unstage --patch";
    kill = "goback --patch";

    history = "log --patch";

    # Inverse of `--intent-to-add` from `git add`. Unadd the existence of all new files.
    # I make a modification to also unstage deleted files, see my post in the conversation
    # https://stackoverflow.com/questions/12994197/how-to-remove-only-intent-to-add-files-from-index-in-git
    unstage-new-files = "!cat <(git diff --name-only --diff-filter=A -z) <(git diff --staged --name-only --diff-filter=D -z) | git restore --staged -q --pathspec-file-nul --pathspec-from-file=- >/dev/null 2>&1";

    # Prettier formatting for `git branch`
    pbranch = "branch --sort=-committerdate --format '%(color:dim white)%(objectname:short)%(color:reset) |%(color:green)%(HEAD)%(color:bold yellow)%(align:22,left)%(refname:short)%(end)%(color:reset) | %(color:cyan)%(align:14,right)%(committerdate:relative)%(end)%(color:reset)%0a--------------------------------------------------'";

    # Switch to branch using fzf. Reference links below
    # https://esc.sh/blog/switch-git-branches-fzf/
    # https://github.com/erees1/dotfiles/blob/b29a94e/git/aliases.zsh#L85-L97
    pswitch =
      /*
      bash
      */
      ''
        !git pbranch --color | \
        fzf --delimiter='\|' --preview-window='bottom' \
        --preview='echo {s2} | cut -c 2- | xargs git show --color | diff-so-fancy' | \
        cut -d '|' -f2 | cut -c 2- | xargs git switch
      '';
  };
}
