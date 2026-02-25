# Dotfiles

Personal dotfiles repository based on Nix Home Manager.

```
dotfiles/
├── flake.nix              # Nix flake configuration
├── flake.lock
├── common/                # Shared configuration
│   ├── default.nix        # Base packages and programs
│   ├── git/               # Git configuration
│   ├── security.nix       # GPG and SSH setup
│   ├── shell/             # ZSH, Atuin, Powerlevel10k
│   └── tools/             # Helper scripts
├── personal/              # Personal profile overrides
│   └── default.nix
├── work/                  # Work profile (git submodule)
└── AGENTS.md
```

## Install

```bash
git clone --recurse-submodules https://github.com/matthiasemde/dotfiles.git ~/dotfiles
cd ~/dotfiles
nix run nixpkgs#home-manager -- switch --flake .
```

## Update

```bash
nix flake update
```

## Requirements

- nix
