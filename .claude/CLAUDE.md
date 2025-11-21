# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Note**: User-level Claude Code instructions (`~/.claude/CLAUDE.md`) are managed declaratively via the NixOS module at `profiles/ai/claude/.claude.md`. Edit that file to modify global Claude behavior across all projects.

## Repository Overview

This is a NixOS systems configuration repository using flake-parts for modular flake management. It manages multiple NixOS hosts with shared profiles, home-manager integration, automated deployment via nixos-anywhere, and cloud infrastructure resources.

## Key Architecture

### Flake Structure
- **flake.nix**: Entry point using flake-parts for modular outputs
- **nix/**: Core flake infrastructure (modules, shell, formatter, checks)
- **packages/**: Custom Nix packages (claude-code, bootstrap)
- **hosts/**: Per-machine NixOS configurations
  - Hydrogen: Laptop (3840x2400@1.75 scale, niri WM)
  - Oxygen: Desktop (dual monitors, niri WM)
  - Lithium: Live USB/bootstrap ISO image
- **profiles/**: Reusable configuration modules organized by category
  - ai/, apps/, browsers/, common/, editors/, graphical/, networking/, peripherals/, security/, terminal/, users/, vcs/, virtualisation/
- **infra/**: Cloud infrastructure resources (VPCs, clusters, storage)
  - Each resource is a Nix package with passthru commands for lifecycle management
  - Public configurations and deployment tooling live here

### Configuration Pattern
Each host imports a common set of profiles from `hosts/default.nix` plus host-specific overrides. Profiles are composable NixOS modules that can be enabled/disabled by including them in the host's imports list.

### Secrets Architecture

This repository is **public** and contains no sensitive data. All secrets are managed in a separate **private** repository imported via SSH-only flake input (`inputs.secrets`).

The secrets repo provides:
- **`vars.*`**: Obfuscated user info and paths (readable at eval time)
- **`nixosModules.default` / `homeModules.default`**: SOPS integration for encrypted secrets
- **Systemd services**: Automatic repo syncing and symlink management

**Claude Code Access:** The secrets repository is accessible via symlink at `secrets/` with full read/write permissions within the sandbox environment.

**Context Management:** When making significant changes to secrets repository structure, configurations, or architecture, update `secrets/.claude/CLAUDE.md` to reflect the new state. This ensures context accuracy for future sessions.

**For detailed secrets architecture documentation, see:** [`secrets/.claude/CLAUDE.md`](../secrets/.claude/CLAUDE.md)

### Infrastructure Architecture

Cloud infrastructure is managed through `infra/` in this repository and `secrets/infra/` in the private secrets repository.

**Public repo (`infra/<resource>/`):**
- Nix packages with passthru commands (plan, deploy, rebuild, destroy, status, etc.)
- Non-sensitive base configurations
- Deployment scripts and tooling

**Private repo (`secrets/infra/<resource>/`):**
- NixOS configurations for infrastructure nodes
- Kubernetes manifests with embedded secrets
- Certificates, CA keys, kubeconfigs
- Planning documents and architecture decisions

**Pattern:** Each infrastructure resource exports a package with lifecycle commands accessible via `nix run .#<resource>.<command>`. The declarative configurations in both repos represent the desired state - deployment commands reconcile cloud resources with these declarations.

**Current resources:**
- **neon**: Personal VPC + Kubernetes cluster (planned)
- **storage**: Backup and long-term storage infrastructure (future)

**For infrastructure planning and architecture, see:** `secrets/infra/PLANNING.md`

### Special Features
- **Impermanence**: Root filesystem erased on boot (profiles/common/impermanence.nix)
- **Disko**: Declarative disk partitioning for automated setup
- **Claude Code Integration**: Custom home-manager module at nix/modules/homeManager/claude-box.nix provides sandboxed claude-code environment with bubblewrap isolation

## Common Development Commands

### Building & Switching
```bash
# Build and switch to new configuration (current host)
sudo nixos-rebuild switch --flake .

# Build and switch for specific host
sudo nixos-rebuild switch --flake .#Hydrogen
sudo nixos-rebuild switch --flake .#Oxygen

# Build without switching (test configuration)
sudo nixos-rebuild build --flake .#<hostname>

# Build ISO image for Lithium bootstrap
nix build .#Lithium
```

### Testing & Validation
```bash
# Format all Nix files with alejandra
nix fmt

# Run statix linter check
nix flake check

# Enter development shell with deployment tools
nix develop
```

### Deployment
```bash
# Bootstrap new machine with nixos-anywhere (from dev shell)
bootstrap --host <hostname> --url <target-ip> [--port <ssh-port>]
# Requires: host SSH keys in pass at systems/ssh/<hostname>/
# Requires: user SSH keys in pass at systems/users/<username>/ssh/
# Requires: disk encryption key in pass at systems/disks/<hostname>
```

### Secrets Management
```bash
# Update secrets flake input
just update-secrets
# Equivalent to: nix flake update secrets && git add flake.lock && git commit
```

## Key Files & Their Purpose

- **hosts/default.nix**: Defines nixosConfigurations and common profile imports
- **nix/lib/default.nix**: Custom library functions (if any)
- **nix/modules/default.nix**: Custom NixOS and home-manager modules
- **packages/default.nix**: Custom packages (claude-code wrapper, bootstrap)
- **profiles/common/nix/default.nix**: Nix daemon settings, caches, experimental features
- **profiles/common/home-manager.nix**: Home-manager integration with useGlobalPkgs
- **profiles/users/primary.nix**: Primary user account configuration
- **nix/modules/homeManager/claude-box.nix**: Full-featured home-manager module for Claude Code with sandboxing

## Adding a New Host

1. Create `hosts/<HostName>/` directory
2. Add `hosts/<HostName>/default.nix` with hardware config and host-specific settings
3. Add `hosts/<HostName>/disk.nix` if using disko
4. Add configuration to `hosts/default.nix` under `flake.nixosConfigurations`
5. Add SOPS secrets for the host in the secrets repository
6. Use `bootstrap` command to deploy

## Important Notes

- **This is a public repository** - All sensitive data lives in the private `.secrets` repository (see Secrets Architecture section)
- This repository uses direnv (`.envrc` contains `use flake`)
- Binary caches include nix-community, numtide, and garnix (EU-based)
- Nix version: 2.30 (explicitly pinned)
- State version: 25.05 for all hosts
- Timezone: Europe/Dublin (configured per-host)
