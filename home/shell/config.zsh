bindkey "^[[1;5C" forward-word   # Ctrl+Right
bindkey "^[[1;5D" backward-word  # Ctrl+Left

bindkey "^[[H" beginning-of-line # Pos1
bindkey "^[[F" end-of-line # End

# Remove the default binding for Ctrl + t
bindkey -r '^T'

# Useful functions for sourcing scripts or setting default values
source_if_exists() { [ -f "$1" ] && source "$1"; }
add_to_path_if_exists() { [ -d "$1" ] && export PATH="$1:$PATH"; }
maybe() {
  type "$1" >/dev/null 2>&1 && "$@"
}
set_default() {
  eval "export $1=\"\${$1:-$2}\""
}

# Set catppuccin colors for fzf: https://github.com/catppuccin/fzf
export FZF_DEFAULT_OPTS=" \
  --color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
  --color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
  --color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
  --color=selected-bg:#45475A \
  --color=border:#313244,label:#CDD6F4"

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
    "git for-each-ref --format='%(refname:short)' --sort=-committerdate refs/ | grep -v HEAD" \
    "git log -5 --color=always --decorate --oneline --graph --abbrev-commit {}" \
    --preview-location=bottom \
    --nowrap \
    --on-select='git checkout "{}"'
}

# Register the git checkout widget and assign a shortcut
zle -N __fzf_git_checkout_widget
bindkey '^T^B' __fzf_git_checkout_widget

# Create a hconfig build prompt
__hconfig_widget() {
  local architectures=("x64-linux" "aarch64")
  local modes=("debug" "release" "tuning")

  # Create an array to store combinations
  local combinations=()

  # Generate combinations
  for architecture in "${architectures[@]}"; do
    for mode in "${modes[@]}"; do
      combinations+=("$architecture $mode")
    done
  done

  # Preview shows the command that would be run
  local build_cmd='hconfig --arch $(echo {} | cut -d" " -f1) --$(echo {} | cut -d" " -f2) --thirdparty-tools=/opt/home/buildbot/halcon/thirdparty/tools --thirdparty-libs=/opt/home/buildbot/halcon/thirdparty -DWITHOUT_EXAMPLES=OFF -DWITH_CCACHE=ON -DWITH_DL_GRAPH_API_INTERNAL=ON'
  local preview_cmd="echo Running hconfig for: {} && echo "" && echo \"$build_cmd\""

  fzf_ui \
    "printf '%s\n' \"\${combinations[@]}\"" \
    "$preview_cmd" \
    --preview-location=bottom \
    --on-select="$build_cmd"
}

# Register the hconfig widget and assign a shortcut
zle -N __hconfig_widget
bindkey '^T^H' __hconfig_widget


# Load p10k config
source_if_exists ~/.p10k.zsh

# Configure default values for env variables
set_default HALCON_SOURCE_DIR "${HOME}/halcon/current"

# MVTec bash tools & halcon build scripts
source_if_exists "${HALCON_SOURCE_DIR}/tools/environment/zsh/all.src"
# source_if_exists "/research/public/mvtec_bash_tools/all.src"
