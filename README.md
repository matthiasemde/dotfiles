# .dotfiles
cotains all of my configuration

```
dotfiles/
├── bootstrap.sh
├── flake.nix
├── home
│   └── common.nix
└── README.md
```

install using
```bash
git clone https://github.com/matthiasemde/dotfiles.git ~/dotfiles
cd ~/dotfiles
nix run github:nix-community/home-manager -- switch --flake .#matthias
```
or
```bash
nix run github:nix-community/home-manager -- switch --flake .#emdem
```

## Installation for unprivileged users


requirements:
- nix
