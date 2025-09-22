# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a NixOS configuration repository using Nix flakes to manage multiple machines and their configurations. The repository manages personal NixOS installations across various machines with modular configuration architecture.

## Build System and Commands

### Flake Commands
- `nix flake update` - Update all flake inputs
- `nix flake update secrets` - Update only the secrets input
- `just update-secrets` - Update secrets flake input and commit changes

### Host Building and Deployment
- `nix build .#nixosConfigurations.<HOST>.config.system.build.toplevel` - Build a host configuration
- `nix run .#packages.x86_64-linux.bootstrap -- --host <HOST> --url root@<IP>` - Bootstrap installation on new machine
- `nixos-rebuild switch --flake .#<HOST_DERIVATION> --target-host <USER>@<TARGET_HOST> --build-host <USER>@<BUILD_HOST> --use-remote-sudo` - Remote rebuild

### Live USB
- `nix build .#packages.x86_64-linux.Lithium` - Build Lithium live USB ISO image

### Development Environment
- `nix develop` - Enter development shell (configured in nix/shell.nix)
- `nix fmt` - Format Nix files using the configured formatter

## Architecture

### Core Structure
- **flake.nix**: Main entry point defining inputs and outputs using flake-parts
- **hosts/**: Individual machine configurations (Hydrogen, Oxygen, Carbon, Lithium)
- **modules/**: Reusable NixOS modules organized by category
- **nix/**: Build system configuration, packages, and utilities

### Host Types
- **Lithium**: Live USB/bootstrap environment for new installations
- **Hydrogen/Oxygen**: Personal desktop/laptop machines with full configurations
- **Carbon**: Server/infrastructure host

### Module Organization
Modules are categorized by functionality:
- **ai/**: AI tools and services configuration
- **apps/**: Application configurations (browsers, productivity tools)
- **common/**: Core system configuration (nix, boot, secrets, impermanence)
- **editors/**: Development tools (git, helix)
- **graphical/**: Display managers, window managers (niri), fonts, nvidia
- **networking/**: SSH, firewall, DNS, tailscale, wifi
- **peripherals/**: Audio, bluetooth, keyboard, monitors, USB
- **security/**: sudo, GPG configuration
- **services/**: System services
- **terminal/**: Terminal emulators (wezterm, ghostty) and shell (zsh)
- **users/**: User account configuration

### Key Technologies
- **nixos-anywhere**: Remote NixOS installation
- **disko**: Disk partitioning and formatting
- **home-manager**: User environment management
- **impermanence**: Stateless system configuration
- **sops-nix**: Secrets management (via private secrets flake)
- **niri**: Wayland compositor
- **Pass**: Password store for secrets during bootstrap

### Secrets Management
- Private secrets flake referenced as git submodule
- SSH keys and disk encryption keys managed via `pass`
- Age keys stored in `/persist/etc/ssh/` for sops decryption
- Bootstrap script handles SSH key deployment during installation

### Impermanence Strategy
- Root filesystem is ephemeral (wiped on boot)
- Persistent data stored in `/persist/` directory
- Home directories and system state selectively persisted

## Commit Guidelines

When creating git commits:
- Use concise, descriptive commit messages that summarize the changes
- Do NOT include co-author attributions or references to Claude/AI tools
- Follow the existing commit message style in the repository
- Keep commit messages focused on what was changed and why
- Make commits for incremental changes as work progresses
- Use discretion to group related small changes into logical commits

## Workflow Guidelines

For collaboration approach:
- **Small itemized changes**: Make direct commits without asking
- **Larger projects/sub-projects**: Present suggestions and await guidance before implementation
- **When unsure**: Always prompt for clarification rather than assuming scope
- Use the TodoWrite tool for multi-step projects to track progress and enable review

## Context Management

When working on tasks, proactively update this CLAUDE.md file with new context that becomes apparent:
- Add project priorities and current focus areas
- Document architectural decisions and patterns discovered
- Update build/deployment procedures as they evolve
- Include planning preferences and workflow patterns
- Record status of ongoing projects (like Carbon deployment)

Use host-specific README.md files for project context:
- Each host directory contains README.md with current status and planning
- Include important historical context and decisions
- Document future planning and next steps
- Keep context close to relevant configurations

This ensures context persists across sessions and improves future collaboration.