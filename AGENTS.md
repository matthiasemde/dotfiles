# AGENTS.md - Long-term Memory for Dotfiles Repository

## Repository Overview

This is a **Personal Nix Home Manager Dotfiles Repository** for user `matthias` (and `emdem` - work profile).

**Repository Structure:**
```
dotfiles/
├── flake.nix              # Public inputs and flake-parts entry point
├── flake.lock             # Public-only dependency graph
├── modules/
│   ├── shared/            # Top-level Dendritic feature modules
│   │   ├── home-manager.nix # Typed profile/host registry
│   │   ├── options.nix    # Home Manager dotfiles options
│   │   ├── git/
│   │   ├── shell/
│   │   └── desktop/
│   └── personal/          # Personal profile and host modules
├── packages/              # Package expressions, not automatically imported
├── work/                  # Optional, independently versioned Git submodule
│   ├── flake.nix          # Work inputs, including internal Stash sources
│   ├── modules/           # Work profile and features
│   └── assets/            # HALCON shell payloads
└── README.md
```

Every configuration Nix file under `modules/` is a flake-parts module. Features
merge deferred Home Manager modules under `flake.modules.homeManager`.
The root exports `flakeModules.shared`, which the work flake evaluates with its
own inputs. Never import work or declare private inputs in the public root.
Identity lives in `home.username`, `home.homeDirectory`, and `dotfiles.identity`,
not `extraSpecialArgs`. Non-Nix assets may be colocated with feature modules.

## Key Technologies & Tools

- **Nix Flakes**: Modern package management and system configuration
- **Home Manager**: User environment management for Nix
- **Dendritic**: flake-parts and import-tree for feature composition
- **ZSH**: Primary shell with Powerlevel10k theme
- **Git**: Version control with extensive aliases and configuration
- **Atuin**: Enhanced shell history with Catppuccin theme
- **FZF**: Fuzzy finder with custom integrations

## User Profiles

### 1. `matthias` (Personal)
- **Email**: matthias@emdemail.de
- **Home**: /home/matthias
- **Shell**: ZSH with Powerlevel10k
- **Special**: Forces ZSH execution via .bash_profile

### 2. `emdem` (Work/MVTec)
- **Email**: matthias.emde@mvtec.com
- **Home**: /home/emdem
- **Config**: Composes shared modules with work inputs in `work/flake.nix`

## Core Packages & Tools

**Development Tools:**
- github-copilot-cli
- lazygit, git-absorb
- nixfmt-rfc-style
- VS Code (set as default editor)

**Terminal Utilities:**
- ripgrep, fzf, fd, bat
- tree, htop, ncdu
- nnn (terminal file manager)
- zoxide (smart cd)

**System Tools:**
- bind (nslookup)
- gnupg, pinentry-curses

## Special Configurations

### Shell Features
- **Custom FZF UI Framework**: Generic `fzf_ui()` function for creating interactive prompts
- **Zoxide Integration**: `Ctrl+T Ctrl+T` for directory navigation
- **Git Branch Checkout**: `Ctrl+T Ctrl+B` for interactive branch switching
- **HConfig Build Helper**: `Ctrl+T Ctrl+H` for HALCON build configurations
- **Catppuccin Theme**: Used for FZF and Atuin

### Git Configuration
- **GPG Signing**: Enabled for commits and tags
- **Signing Key**: B553F8169E97D0E33563F977DE0DBC6804FF7C75
- **GitAlias Integration**: External git aliases from GitAlias project
- **Advanced Features**: 
  - Diff algorithm: histogram
  - Merge conflict style: zdiff3
  - Auto-rebase on pull
  - Auto-setup remote on push

### Work-Specific (HALCON/MVTec)
- **HALCON Environment**: Integration with HALCON development tools
- **Benchmark Tools**: Aliases for hbenchop (HALCON benchmarking)
- **Build System**: hconfig, hbuild integration
- **Network Share Sync**: `install_on_network_share()` function
- **License Management**: Aliases for different HALCON license versions

## Installation Commands

```bash
# Personal profile (automatically selects user@host when available)
home-manager switch --flake ~/dotfiles

# Work profile (one activation for shared and work features)
home-manager switch --flake ~/dotfiles/work

# Update public inputs from the public root
nix flake update

# Update work inputs from the work directory
nix flake update --flake ~/dotfiles/work
```

Work's independent lock requires the public shared-module export to be
published first. See README.md for development overrides and publishing order.
Changes in work must be committed in that repository separately before updating
the public submodule pointer. Do not persist local development input overrides.

## Key Aliases & Functions

**Configuration Editing:**
- Shared shell config: `modules/shared/shell/`
- Personal identity and host assignment: `modules/personal/profile.nix`
- Work identity and host assignment: `work/modules/profile.nix`

**HALCON Development:**
- `hb()` - Build and set environment
- `hbu()`, `hbdlu()` - Build specific targets
- `hu()`, `hdlu()` - Run unit tests with filter
- `sn` - Sync to network share
- Various `hb_*` benchmark functions

**Utilities:**
- `ll` - ls -la
- `c` - clear
- `size` - du -sh
- `mem` - time with memory usage
- `tag` - Generate ctags for HALCON source

## Git Repository State

- **Current Branch**: main
- **Status**: 10 commits ahead of origin/main
- **Stash**: 1 entry (WIP on authorized_keys feature)
- **Recent Work**: Integration of Home Manager without root privileges

## Important Notes

1. **No Root Required**: Repository is designed to work without root privileges
2. **Multi-User Setup**: Supports both personal and work profiles
3. **Modular Design**: Dendritic features compose via top-level flake-parts modules
4. **Work Integration**: Heavy integration with MVTec/HALCON development workflow
5. **Theme Consistency**: Catppuccin theme used across tools (Atuin, FZF)

## Environment Variables

- `EDITOR` / `VISUAL`: "code --wait" (VS Code)
- `HALCON_SOURCE_DIR`: "${HOME}/halcon/current"
- `FZF_DEFAULT_OPTS`: Catppuccin color scheme
- `HALCON_LICENSE_FILE`: Configurable license paths

## Maintenance

- Regular `nix flake update` to keep packages current
- Git configuration includes auto-updates and pruning
- Home Manager state version: 25.05