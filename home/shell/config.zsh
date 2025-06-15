bindkey "^[[1;5C" forward-word   # Ctrl+Right
bindkey "^[[1;5D" backward-word  # Ctrl+Left

bindkey "^[[H" beginning-of-line # Pos1
bindkey "^[[F" end-of-line # End

# Remove the default binding for Ctrl + t
bindkey -r '^T'

# Generic function to create a fzf ui prompt
# Usage: fzf_ui INPUT_COMMAND PREVIEW_COMMAND [FZF_ARGS...]
fzf_ui() {
  local input_cmd="$1"
  local preview_cmd="$2"
  shift 2

  eval "$input_cmd" | fzf \
    --preview="$preview_cmd" \
    --preview-window=right:50%:wrap \
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
    "$@"
}

# Create a zoxide ui prompt
__zoxide_widget() {
  local dir
  # dir=$(fzf_ui "zoxide query -l" "ls -lah --color=always {}")
  dir=$(fzf_ui "zoxide query -l" "tree -C -L 2 {} 2>/dev/null")
  [[ -n $dir ]] && cd "$dir"
}

# Register the zoxide widget and assign an shortcut
zle -N __zoxide_widget
bindkey '^T^T' __zoxide_widget

# Create a widget for interactively checking out git branches
__fzf_git_checkout_widget() {
  local branch
  branch=$(fzf_ui \
    "git for-each-ref --format='%(refname:short)' --sort=-committerdate refs/ | grep -v HEAD" \
    "git log -5 --color=always --decorate --oneline --graph --abbrev-commit {}")

  [[ -n $branch ]] && git checkout "$branch"
}

# Register the git checkout widget and assign a shortcut
zle -N __fzf_git_checkout_widget
bindkey '^T^B' __fzf_git_checkout_widget


# Load p10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
