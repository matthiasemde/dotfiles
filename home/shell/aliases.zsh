# zsh aliases and functions

alias brc="code ~/dotfiles/home/shell/config.z"
alias als="code ~/dotfiles/home/shell/zsh_aliases.nix"
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
alias get=printenv | grep
alias sn=install_on_network_share
