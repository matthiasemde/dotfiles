# Bash-specific interactive shell configuration
# Sourced from programs.bash.initExtra (after common shellenv is already loaded)

shopt -s checkwinsize
shopt -s direxpand

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set variable identifying the chroot (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# Prompt: colored if the terminal supports it
case "$TERM" in
  xterm-color|*-256color) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

case "$TERM" in
  xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
esac

# Enable programmable completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Disable the terminal bell
bind 'set bell-style none'

# Modify PS1: strip trailing prompt chars from git segment, add newline + colored $
PS1=$(echo "$PS1" | sed "s/\(\$(__git_ps1)\).*/\1/")
PS1=$'\n'"$PS1"$'\n\[\e[1;35m\]\$ \[\e[0m\]'

# worktrunk shell integration
if command -v wt >/dev/null 2>&1; then eval "$(wt config shell init bash)"; fi

# Check whether one or more programs are installed
is_installed() {
  (( $# >= 1 )) || return 1
  local -i ret=0
  local program
  for program in "$@"; do
    command -v "$program" &>/dev/null || { ret=$((ret + 1)); break; }
  done
  return $ret
}

# Interactive git branch checkout via fzf (Ctrl+T Ctrl+B)
__fzf_custom_git_checkout_branch__() {
  is_installed git || { echo "git is required" >&2; return 1; }
  git rev-parse HEAD &>/dev/null || { echo "not inside git repository" >&2; return 1; }
  local cmd revision
  cmd="git for-each-ref --color=always refs/ --format='%(refname:short)' --sort=-committerdate | grep -v HEAD"
  revision="$(eval "$cmd" | fzf --no-preview +m | tr -d '[:space:]')"
  [[ "$revision" = "" ]] && { echo "No revision selected." >&2; return 1; }
  if git show-ref --heads "$revision" &>/dev/null; then
    printf 'git checkout %q' "$revision"
  elif git show-ref --tags "$revision" &>/dev/null; then
    printf 'git checkout -b %q %q' "tmp-$revision" "$revision"
  else
    printf 'git checkout --track %q' "$revision"
  fi
}

# Interactive SSH remote selection via fzf (Ctrl+T Ctrl+M)
__fzf_custom_ssh_remote__() {
  [[ -r $HOME/.ssh/config ]] || { echo "ssh config not readable" >&2; return 1; }
  [[ -d $HOME/.ssh/hosts ]] || { echo "~/.ssh/hosts directory not found" >&2; return 1; }
  local cmd host
  cmd="grep -h 'Host ' ~/.ssh/hosts/* | grep -v '*' | sort -u | cut -b 6- | tr ' ' '\n'"
  host="$(eval "$cmd" | fzf +m)" && printf 'ssh %q' "$host"
}

# Key bindings — these must run after fzf has set up its own Ctrl+T binding
bind -r '\C-t'
bind '"\C-t\C-t": "__zoxide_zi \C-m"'
bind '"\C-t\C-b": " \C-w\C-k\C-u `__fzf_custom_git_checkout_branch__`\e\C-e\er\C-m\C-y\C-h\e \C-y\ey\C-x\C-x\C-d"'
bind '"\C-t\C-m": " \C-w\C-k\C-u `__fzf_custom_ssh_remote__`\e\C-e\er\C-m\C-y\C-h\e \C-y\ey\C-x\C-x\C-d"'
