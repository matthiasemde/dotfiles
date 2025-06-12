# Remove the default binding for Ctrl + t
bindkey -r '^T'


# Add keyboard shortcut for accessing the zoxide db
__zoxide_widget() {
  __zoxide_zi
  zle accept-line
}

# Register the zoxide widget and assign an shortcut
zle -N __zoxide_widget
bindkey '^T^T' __zoxide_widget


# Create an fzf command checkout git branches in a project
function __fzf_custom_git_checkout_branch_widget() {
    git rev-parse HEAD &> /dev/null || { error "not inside git repository"; return 1; }

    local cmd revision
    cmd="git for-each-ref --color=always refs/ --format='%(refname:short)' --sort=-committerdate | grep -v HEAD" # this only
    revision="$(eval "$cmd" | \
            $(__fzfcmd) --no-preview +m | \
            tr -d '[:space:]')"

    [[ "$revision" = "" ]] && { error "No revision selected."; return 1; }

    # Different ways to checkout for local revision, tag, or remote revision
    if $(git show-ref --heads "$revision" &> /dev/null); then
        printf 'git checkout %q' "$revision"
    elif $(git show-ref --tags "$revision" &> /dev/null); then
        printf 'git checkout -b %q %q' tmp-"$revision" "$revision"
    else
        printf 'git checkout --track %q' "$revision"
    fi

    zle accept-line
}

# Register the git checkout widget and assign a shortcut
zle -N __fzf_custom_git_checkout_branch_widget
bindkey '^T^B' __fzf_custom_git_checkout_branch_widget


# Load p10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
