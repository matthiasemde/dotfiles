# Portable shell environment - sourced by both bash and zsh
# POSIX-compatible: no bash-specific or zsh-specific syntax

# Utility functions
source_if_exists() { [ -f "$1" ] && source "$1"; }
maybe() { type "$1" >/dev/null 2>&1 && "$@"; }
set_default() { eval "export $1=\"\${$1:-$2}\""; }

# Memory limit
ulimit -m 15000000

# # GPG: set TTY and refresh the agent's idea of the tty
# export GPG_TTY=$(tty)
# gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 || true

# Display: detect Xorg display from running process list
export DISPLAY=$(maybe ps x 2>/dev/null | sed -n 's/.*Xorg \(:[0-9]\+\).*/\1/p')

# FZF: Catppuccin Mocha theme
export FZF_DEFAULT_OPTS=" \
  --color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
  --color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
  --color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
  --color=selected-bg:#45475A \
  --color=border:#313244,label:#CDD6F4"

# Zoxide: suppress startup warnings
export _ZO_DOCTOR=0

alias ll="eza -la"
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
lg() { git lg1 "$@"; }
prune() { git fetch --prune "$@"; }
diff() { echo "git difftool $@ HEAD" && yes | git difftool "$@"; }
diffl() { diff HEAD~; }
diffm() { diff $(git merge-base origin/master HEAD) "$@"; }
files() { git show --name-only "$@"; }
gls() { git branch | grep -v "^\*" | head -10 | nl; }

get() { printenv | grep "$@"; }
