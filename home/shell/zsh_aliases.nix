{ ... }: {
  programs.zsh.shellAliases = {
    hmu = "nix build .#emdem && ./result/bin/home-manager-generation";

    ll = "ls -la"
  };
}
