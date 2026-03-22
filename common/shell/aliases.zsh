# zsh aliases and functions
alias brc="code ~/dotfiles/common/shell/config.zsh"
alias als="code ~/dotfiles/common/shell/aliases.zsh"
# Home Manager update: auto-detects user@hostname, falls back to plain user
hmu() {
  local host=$(hostname)
  local target="$USER@$host"
  # Check if user@host target exists, otherwise fall back to plain user
  if nix eval ~/dotfiles#homeConfigurations.\"$target\" --apply 'x: true' 2>/dev/null; then
    echo "Building: $target"
    nix build ~/dotfiles#homeConfigurations.\"$target\".activationPackage && ./result/activate
  else
    echo "No host config for '$host', using default: $USER"
    nix build ~/dotfiles#homeConfigurations.\"$USER\".activationPackage && ./result/activate
  fi
}

alias ll="ls -la"
alias c="clear"
alias size="du -sh"
alias untar="tar -xvf"
alias which="type"
alias mem="/usr/bin/time -f \"%M\"kb"

## #############################################################
## alias functions for git
## #############################################################

status() { git status "$@"; }
fetch() { git fetch "$@"; }
checkout() { git checkout "$@"; }
pull() { git pull "$@"; }
push() { git push "$@"; }
commit() { git commit "$@"; }
amend() { git commit --amend "$@"; }
ammend() { amend "$@"; }
fix() { git commit --fixup "$@"; }
fixall() { git commit -a --fixup "$@"; }
rebase() { git rebase -i "$@"; }
rebasem() { rebase origin/master "$@"; }
rebasec() { git rebase --continue; }
uncommit() { git reset --soft HEAD~1 "$@"; }
cherry() { git cherry-pick -m 1 -e "$@"; }
glog() { git lg1 "$@"; }
prune() { git fetch --prune "$@"; }
diff() { echo "git difftool $@ HEAD" && yes | git difftool "$@"; }
diffl() { diff HEAD~; }
diffm() { diff $(git merge-base origin/master HEAD) "$@"; }
files() { git show --name-only "$@"; }
gls() { git branch | grep -v "^\*" | head -10 | nl; }

get() { printenv | grep "$@"; }
