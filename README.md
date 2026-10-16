# Dotfiles

Home Manager configurations using the [Dendritic pattern](https://github.com/mightyiam/dendritic),
with independent public and work flakes. Each environment needs only one switch.

```
dotfiles/
├── flake.nix              # Public inputs and flake-parts entry point
├── flake.lock             # Public dependencies only
├── modules/
│   ├── shared/            # Reusable features and profile/host construction
│   │   ├── options.nix    # Home Manager dotfiles options
│   │   ├── shell/
│   │   ├── desktop/
│   │   └── ...
│   └── personal/          # Personal profile, Thunderbird and host overrides
├── packages/              # Package expressions excluded from module imports
└── work/                  # Optional, separately versioned Git submodule
    ├── flake.nix          # Work inputs, including internal Stash repositories
    ├── flake.lock         # Independent work dependency graph (generated at work)
    ├── modules/           # Work profile, packages, shell and host assignments
    └── assets/            # HALCON shell configuration
```

## Architecture

All configuration Nix files under `modules/` are top-level flake-parts modules,
automatically imported with import-tree. Features contribute deferred Home
Manager modules under `flake.modules.homeManager.base`, `personal`, or `work`.
Shell scripts, QML, and other non-Nix assets can remain alongside their features;
they are not automatically imported. Package expressions live under `packages/`.

`modules/shared/home-manager.nix` defines typed `dotfiles.profiles` and
`dotfiles.hosts` registries and generates the generic and `user@host` targets.
Home Manager options such as `home.username` and `home.homeDirectory` carry
identity information; `dotfiles.identity` carries email and the signing key.
Features capture upstream inputs at the top level, without `extraSpecialArgs`.

The public flake exports `flakeModules.shared`. The work flake evaluates these
same top-level modules with **its own inputs**, including the delayed work
nixpkgs. It does not reuse an already instantiated personal configuration.
The public flake neither imports nor fetches work, and can be cloned, evaluated,
and updated without private repository access.

Dendritic organizes feature composition; the **separate flake entry points and
lock files** isolate private inputs. Conditional Home Manager imports alone do
not establish that boundary.

### Adding a new host

Add a top-level module under `modules/personal/hosts/` (or `work/modules/hosts/`):

```nix
{ ... }:
{
  dotfiles.hosts.myhost = {
    profile = "matthias";
    module = {
      dotfiles.desktop.enable = true;
      dotfiles.desktop.wallpaper = "/absolute/path/to/wallpaper.jpg";
    };
  };
}
```

No additional imports list is necessary. Omit the desktop settings for headless
hosts. Generic profiles remain headless unless their profile enables a desktop.

## Install

```bash
git clone https://github.com/matthiasemde/dotfiles.git ~/dotfiles
home-manager switch --flake ~/dotfiles
```

Home Manager itself selects the matching `user@host` target, falling back to the
generic username. If it is not installed yet, use
`nix run nixpkgs#home-manager -- switch --flake ~/dotfiles`.

At work, initialize the optional submodule and switch the composed work profile:

```bash
git -C ~/dotfiles submodule update --init work
home-manager switch --flake ~/dotfiles/work
```

This builds and activates shared and work settings together, not in two steps.

## Flake targets

| Flake | Target | Description |
|---|---|---|
| `~/dotfiles` | `matthias` | Personal, generic/headless |
| `~/dotfiles` | `matthias@vogel` | Personal desktop |
| `~/dotfiles` | `matthias@hindemith` | Retained host with an existing invalid desktop option |
| `~/dotfiles/work` | `emdem` | Work, generic/headless |
| `~/dotfiles/work` | `emdem@bemba` | Work on bemba, currently headless |

Use `--flake ~/dotfiles#matthias@vogel` to select a target explicitly.
Work targets are intentionally no longer exported by the public root flake.
The existing hindemith error is not fixed by this refactor: its boolean
`dotfiles.desktop` must eventually become an option set with an appropriate
wallpaper.

## Update

```bash
# Public inputs; never requires work credentials
cd ~/dotfiles && nix flake update

# Work inputs, including the pinned public base; requires work access
cd ~/dotfiles/work && nix flake update
```

The common profile enables automatic Home Manager updates at `04:40` and daily
Nix garbage collection. Personal updates use `github:matthiasemde/dotfiles`;
work updates use `git+ssh://git@github.com/memmvtec/dotfiles.git`.
The services are defined in `modules/shared/services.nix` and can be overridden
in a profile's or host's Home Manager module:

```nix
dotfiles.autoUpdate.enable = false;
dotfiles.nixGc.enable = false;
```

Set `dotfiles.autoUpdate.flake` to change the flake reference or
`dotfiles.autoUpdate.dates` to change the systemd calendar schedule.

### Publishing this migration

The public shared-module export must be published before the work flake can
resolve it normally. Then run `nix flake lock` inside `work/` and commit that
repository's changes separately. Only advance the public repository's submodule
pointer after the work commit is available.

Until publication, evaluate the work tree using a local public-base override:

```bash
nix eval ~/dotfiles/work#homeConfigurations.emdem.activationPackage.drvPath \
  --override-input dotfiles "git+file://$HOME/dotfiles" --no-write-lock-file
```

New files must be tracked in their owning repository for Git-backed flake
references to include them. The development override must not be persisted in
`work/flake.lock`; keep the normal base input a pinned public GitHub reference.

## Checks

Public CI runs formatting, flake checks, and activation-derivation evaluation for
the supported personal targets without checking out work. It also rejects
non-public input sources in the public lock graph. The known hindemith error is
documented above and excluded from supported-target evaluation.

Run `nix fmt -- --fail-on-change` and `nix flake check` in each flake directory.
The formatter excludes `work/**` when run from the public root so that each Git
repository owns its formatting. Work evaluation requires internal access and,
until publication, the local override described above.
