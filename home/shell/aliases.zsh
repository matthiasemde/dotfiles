# zsh aliases and functions

alias brc="code ~/dotfiles/home/shell/config.zsh"
alias als="code ~/dotfiles/home/shell/aliases.zsh"
alias hmu="nix build ~/dotfiles#$USER && ./result/bin/home-manager-generation"

alias ll="ls -la"
alias c="clear"
alias license_22_11="export HALCON_LICENSE_FILE=/halcon/license-22.11/license_floating.dat"
alias license_24_11="export HALCON_LICENSE_FILE=/halcon/license-24.11/license_floating.dat"
alias size="du -sh"
alias untar="tar -xvf"
alias which="type"
alias mem="/usr/bin/time -f \"%M\"kb"

alias tag="cd $HOME/halcon/current && ctags -V --c-kinds=+xfdev --cpp-kinds=+xfdev --fields=+iaS source/hlib/**/*.c* source/hlib/**/*.h* include/**/*.h* tests/tools/gmock/gtest/include/gtest/gtest.h source/hlib_unittests/**/*.h* source/hlib_unittests/**/*.c* && mv tags .tags && cd -"

alias sethhb="seth /mvtec/home/buildbot/halcon/benchmark_tests/hbenchop/builds/master/x64-linux-release"

alias vtune="/halcon/toolchains/x64-linux/intel_oneapi/vtune/latest/bin64/vtune-gui"

hdev() { hdevelop "$@" & }
get() { printenv | grep "$@"; }

install_on_network_share() {
  # Get the absolute path of the current directory
  local current_dir
  current_dir=$(pwd)

  # Extract the relative path after the 'build' directory
  local relative_path
  relative_path=${current_dir#*build/}

  # Validate that we are indeed inside a build/<arch>/ directory
  if [[ "$current_dir" == *"/build/"* && -n "$relative_path" ]]; then
    local remote_path="/mvtec/home/$USER/halcon/current/build/$relative_path"
    echo "Syncing to: $remote_path"
    rsync -a --progress ./ "$remote_path"
  else
    echo "Error: This function must be run from inside halcon/current/build/<arch>/"
    return 1
  fi
}

alias sn=install_on_network_share

hu() { hlib_unittests --gtest_filter=*"$@"*; }
hdlu() { hdl_unittests --gtest_filter=*"$@"*; }

alias hrun="hrun -Pp /home/emdem/halcon/current/tests/templates/procedures/"
alias hodor="hodor -p /home/emdem/halcon/current/tests/templates/procedures/"

hb() { hbuild "$@" && seth; }
hbu() { hbuild hlib_unittests "$@" && seth; }
hbdlu() { hbuild hdl_unittests "$@" && seth; }

function hb_find() { hbenchop --skip help | grep "$1"; }
function hb_exec() { echo "hbenchop $@" && hbenchop $@; }
function hb_exec_range() { hb_exec "-g $1 -e $2 ${@:3}"; }
function hb_exec_one() { hb_exec_range $1 $1 ${@:2}; }
function hb_bm() { echo "$1 hbenchop ${@:2}" && $1 hbenchop ${@:2}; }
function hb_bm_range() { hb_bm "nice -n0 taskset -c 3" "-g $1 -e $2 -a 2 ${@:3}"; }
function hb_bm_arm_range() { hb_bm "nice -n0 taskset -c 4" "-g $1 -e $2 -a 2 ${@:3}"; }
function hb_bm_one() { hb_bm_range $1 $1 ${@:2}; }
function hb_bm_arm_one() { hb_bm_arm_range $1 $1 ${@:2}; }

alias hbfind=hb_find
alias hbexr=hb_exec_range
alias hbex1=hb_exec_one
alias hbbm=hb_bm
alias hbbmr=hb_bm_range
alias hbbmarmr=hb_bm_arm_range
alias hbbm1=hb_bm_one
alias hbbmarm1=hb_bm_arm_one
alias sethhb="seth /mvtec/home/buildbot/halcon/benchmark_tests/hbenchop/builds/master/x64-linux-release"
