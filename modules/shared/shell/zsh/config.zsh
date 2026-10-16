# Make word operations behave more like bash:
autoload -U select-word-style
select-word-style bash

# Ctrl+Backspace: stop at punctuation/path separators
zle -N backward-kill-subword backward-kill-word-match
zstyle ':zle:backward-kill-subword' word-style normal
bindkey '^H' backward-kill-subword

# Alt+Backspace: delete back to whitespace only
zle -N backward-kill-space-word backward-kill-word-match
zstyle ':zle:backward-kill-space-word' word-style space
bindkey '^[^?' backward-kill-space-word

# Ctrl+Left / Ctrl+Right: move by subwords (stop at / . - _ etc.)
zle -N backward-subword backward-word-match
zle -N forward-subword  forward-word-match
zstyle ':zle:backward-subword' word-style normal
zstyle ':zle:forward-subword'  word-style normal
bindkey '^[[1;5D' backward-subword
bindkey '^[[1;5C' forward-subword

# Alt+Left / Alt+Right: move by space-delimited WORDs
zle -N backward-space-word backward-word-match
zle -N forward-space-word  forward-word-match
zstyle ':zle:backward-space-word' word-style space
zstyle ':zle:forward-space-word'  word-style space
bindkey '^[[1;3D' backward-space-word
bindkey '^[[1;3C' forward-space-word

bindkey "^[[H" beginning-of-line # Pos1
bindkey "^[[F" end-of-line # End

bindkey "^[[3~" delete-char # Del

bindkey '^Z' undo
bindkey '^[z' redo

# Remove the default binding for Ctrl + t
bindkey -r '^T'

# Tab completion: complete common prefix first, list options on second tab (bash-like)
setopt NO_AUTO_MENU
setopt AUTO_LIST

# Ctrl+L: clear screen and scrollback buffer
__clear_screen() { printf '\033[2J\033[3J\033[H'; zle .reset-prompt; }
zle -N __clear_screen
bindkey '^L' __clear_screen

# Ctrl+V: remove quoted-insert so terminal paste (Ctrl+V) works
bindkey -r '^V'

# Generic function to create a fzf ui prompt
# Usage: INPUT_COMMAND PREVIEW_COMMAND [--preview-location=right|bottom] [--wrap|--nowrap] [--on-select=CMD]
fzf_ui() {
  local input_cmd="$1"
  local preview_cmd="$2"
  shift 2

  # Defaults
  local preview_loc="right"
  local wrap="wrap"
  local on_select=""

  # Parse options
  while [[ "$1" == --* ]]; do
    case "$1" in
      --preview-location=*)
        preview_loc="${1#*=}"
        ;;
      --wrap)
        wrap="wrap"
        ;;
      --nowrap)
        wrap="nowrap"
        ;;
      --on-select=*)
        on_select="${1#*=}"
        ;;
    esac
    shift
  done

  local selection
  selection=$(eval "$input_cmd" | fzf \
    --preview="$preview_cmd" \
    --preview-window="$preview_loc:50%:$wrap" \
    --layout=reverse \
    --height=45% \
    --border=sharp \
    --info=inline \
    --no-sort \
    --cycle \
    --bind=ctrl-z:ignore,btab:up,tab:down \
    --exact \
    --ansi \
    --exit-0 \
  )

  [[ -z "$selection" ]] && return

  # If an action was passed, substitute {} with the selected item
  if [[ -n "$on_select" ]]; then
    local final_cmd="${on_select//\{\}/$selection}"
    eval "$final_cmd; zle accept-line"
  else
    echo "$selection"
  fi
}

# Create a zoxide ui prompt
__zoxide_widget() {
  #"zoxide query -l" "ls -lah --color=always {}"
  fzf_ui \
    "zoxide query -l" "tree -C -L 2 {} 2>/dev/null" \
    --nowrap \
    --on-select='cd "{}"'
}

# Register the zoxide widget and assign an shortcut
zle -N __zoxide_widget
bindkey '^T^T' __zoxide_widget

# Create a widget for interactively checking out git branches
__fzf_git_checkout_widget() {
  fzf_ui \
    "git for-each-ref --format='%(refname:short)' --sort=-committerdate refs/heads/;\
     git for-each-ref --format='%(refname:short)' --sort=-committerdate refs/remotes/origin/ | head -n 50" \
    "git log -5 --color=always --decorate --oneline --graph --abbrev-commit {}" \
    --preview-location=bottom \
    --nowrap \
    --on-select='git checkout "{}"'
}

# Register the git checkout widget and assign a shortcut
zle -N __fzf_git_checkout_widget
bindkey '^T^B' __fzf_git_checkout_widget

# Load p10k config
source_if_exists ~/.p10k.zsh

gclean() {
  local current=$(git rev-parse --abbrev-ref HEAD)

  for b in $(git for-each-ref --format='%(refname:short)' refs/heads/); do
    if [[ "$b" == "$current" ]]; then
      echo "Skipping currently checked-out branch: $b"
      continue
    fi

    # Get configured upstream (may be empty or stale)
    local track=$(git for-each-ref --format='%(upstream:short)' "refs/heads/$b")

    # Check if remote-tracking ref actually exists
    if [[ -n "$track" && -n "$(git show-ref "refs/remotes/$track")" ]]; then
      local realtrack="$track"
    else
      local realtrack=""
    fi

    echo
    echo "----------------------------------------"
    echo "Local branch: $b"
    if [[ -n "$realtrack" ]]; then
      echo "  Tracks (exists): $realtrack"
    else
      echo "  No valid remote tracking branch"
    fi

    echo
    echo "Last 3 commits on $b:"
    git lg1 -3 "$b"

    echo
    read -q "?Delete branch '$b'? (y/N) "
    echo
    if [[ "$REPLY" == "y" ]]; then
      echo "Deleting $b ..."
      git branch -D "$b"
    else
      echo "Keeping $b"
    fi
  done
}
