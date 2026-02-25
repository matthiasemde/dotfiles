# Dotfiles
Dotfile repository based on Nix Home Manager

```
dotfiles/
├── AGENTS.md
├── flake.lock
├── flake.nix
├── home
│   ├── common.nix
│   ├── emdem.nix
│   ├── git
│   │   ├── default.nix
│   │   └── git.nix
│   ├── matthias.nix
│   ├── security.nix
│   └── shell
│       ├── aliases.zsh
│       ├── atuin.nix
│       ├── config.zsh
│       ├── default.nix
│       └── zsh.nix
└── README.md

4 directories, 14 files
```

Install using
```bash
git clone https://github.com/matthiasemde/dotfiles.git ~/dotfiles
cd ~/dotfiles
nix run nixpkgs#home-manager -- switch --flake .
```

## Update using
```bash
nix flake update
```

requirements:
- nix
