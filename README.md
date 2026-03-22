# Dotfiles

Personal dotfiles repository based on Nix Home Manager with per-host configuration support.

```
dotfiles/
├── flake.nix              # Nix flake configuration (mkConfig helper)
├── flake.lock
├── options.nix            # Custom options (hostname, desktop)
├── hosts/                 # Host-specific configurations
│   └── bemba.nix          # Example: desktop workstation
├── common/                # Shared configuration
│   ├── default.nix        # Base packages and programs
│   ├── git/               # Git configuration
│   ├── security.nix       # GPG and SSH setup
│   ├── shell/             # ZSH, Atuin, Powerlevel10k
│   └── tools/             # Helper scripts
├── personal/              # Personal profile overrides
│   └── default.nix
├── work/                  # Work profile (git submodule)
│   └── hosts/             # Work host-specific overrides (optional)
└── AGENTS.md
```

## Architecture

Configuration is layered: **common → user (personal/work) → host**.

- **`options.nix`** defines `dotfiles.hostname` (string) and `dotfiles.desktop` (bool, default `false`/headless)
- **`hosts/<hostname>.nix`** sets host-specific options (e.g. `dotfiles.desktop = true`)
- **`work/hosts/<hostname>.nix`** optional work-specific host overrides from the submodule
- **`flake.nix`** generates `user@host` targets automatically from the `hosts` mapping

Any module can use `config.dotfiles.desktop` to conditionally include desktop-only config.

### Adding a new host

1. Create `hosts/<hostname>.nix` with host-specific settings
2. Add the host to the `hosts` mapping in `flake.nix`: `<hostname> = "<user>";`
3. Optionally add `work/hosts/<hostname>.nix` for work-specific overrides

## Install

```bash
git clone --recurse-submodules https://github.com/matthiasemde/dotfiles.git ~/dotfiles
cd ~/dotfiles
nix run nixpkgs#home-manager -- switch --flake .
```

The `hmu` alias auto-detects the hostname and uses the matching `user@host` target (falling back to the plain user default if no host config exists).

## Flake targets

| Target | Description |
|---|---|
| `matthias` | Personal profile, generic/headless |
| `emdem` | Work profile, generic/headless |
| `emdem@bemba` | Work profile on bemba (desktop) |

## Update

```bash
nix flake update
```

## Requirements

- nix
