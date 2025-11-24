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

**Note:** This section covers **personal host deployment** (Hydrogen, Oxygen, Lithium). Infrastructure deployment (Neon cluster, Headscale, etc.) uses a separate process defined in `infra/` and will be implemented separately.

#### Bootstrap Prerequisites (Dependency Chain)

Before deploying a new host via `bootstrap`, the following must be set up in the secrets repository (in order of dependency):

1. **Age Keys & SOPS Configuration**
   - Admin age key configured in `secrets/.sops.yaml`
   - Host age key derived from SSH host key (generated on first boot, but you can pre-generate)
   - User age key for primary user (for secrets decryption post-boot)

2. **Host SSH Keys** (in `pass` at `systems/ssh/<hostname>/`)
   - `id_ed25519` (private key) - Used by NixOS for SOPS decryption at runtime
   - `id_ed25519.pub` (public key)
   - These can be generated with: `ssh-keygen -t ed25519 -f /tmp/host_key -N ""`

3. **User SSH Keys** (in `pass` at `systems/users/<username>/ssh/`)
   - `id_ed25519` (private key) - For user login and SOPS decryption of user secrets
   - `id_ed25519.pub` (public key)

4. **Disk Encryption Key** (in `pass` at `systems/disks/<hostname>`)
   - Random 32-byte key for LUKS encryption (if using disko with encryption)
   - Generate with: `head -c 32 /dev/urandom | base64`

5. **Host SOPS Secrets File** (in `secrets/hosts/<hostname>.secrets.yaml`)
   - Encrypted with admin key + host age key
   - Contains host-specific secrets (user password, etc.)
   - File must exist and be readable before bootstrap

6. **User SOPS Secrets File** (in `secrets/users/<username>.secrets.yaml`)
   - Encrypted with admin key + user age key
   - Decrypted at runtime using user's SSH key
   - Consumed by home-manager on user login

**Workflow:**
```bash
# 1. Generate and store SSH keys in pass
ssh-keygen -t ed25519 -f /tmp/host_key -N "" && pass insert systems/ssh/<hostname>/id_ed25519 < /tmp/host_key

# 2. Generate and store disk key
head -c 32 /dev/urandom | base64 | pass insert systems/disks/<hostname>

# 3. Create encrypted SOPS secrets files (admin + host key)
sops secrets/hosts/<hostname>.secrets.yaml

# 4. Create encrypted user secrets (admin + user key)
sops secrets/users/<username>.secrets.yaml

# 5. From systems repo dev shell, run bootstrap
bootstrap --host <hostname> --url <target-ip> [--port <ssh-port>]
```

#### Bootstrap Command
```bash
# From dev shell (nix develop)
bootstrap --host <hostname> --url <target-ip> [--port <ssh-port>]
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

## Adding a New Host (Personal Hosts)

This process applies to personal hosts (Hydrogen, Oxygen, Lithium). Infrastructure hosts are deployed via separate infrastructure-specific processes in `infra/`.

**Configuration Setup:**
1. Create `hosts/<HostName>/` directory
2. Add `hosts/<HostName>/default.nix` with hardware config and host-specific settings
3. Add `hosts/<HostName>/disk.nix` if using disko
4. Add configuration to `hosts/default.nix` under `flake.nixosConfigurations`

**Secrets Setup (in secrets repository):**
5. Follow the bootstrap dependency chain documented above in "Deployment" section
   - Generate host/user SSH keys and store in `pass`
   - Generate and store disk encryption key
   - Create encrypted SOPS secrets files for host and user

**Deploy:**
6. Run `bootstrap --host <HostName> --url <ip>` from `nix develop` shell

**Post-Bootstrap:**
- On first boot, host age key is generated from SSH host key at `/persist/etc/ssh/ssh_host_ed25519_key`
- User secrets are decrypted using user's SSH key from `pass`
- Impermanence clears root filesystem but `/persist/` retains SSH keys for SOPS decryption

## Important Notes

- **This is a public repository** - All sensitive data lives in the private `.secrets` repository (see Secrets Architecture section)
- This repository uses direnv (`.envrc` contains `use flake`)
- Binary caches include nix-community, numtide, and garnix (EU-based)
- Nix version: 2.30 (explicitly pinned)
- State version: 25.05 for all hosts
- Timezone: Europe/Dublin (configured per-host)
