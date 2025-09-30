# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal NixOS systems configuration repository managing multiple machines using Nix Flakes. The architecture is modular with reusable profiles and host-specific configurations. All system configuration is declarative using the Nix language.

## Core Commands

### Development Environment
- `nix develop` - Enter development shell with all tools
- `nix fmt` - Format Nix code using alejandra
- `nix flake check` - Run checks including statix linting
- `just update-secrets` - Update secrets flake input and commit changes

### System Operations
- `nixos-rebuild switch --flake .#HOSTNAME` - Deploy configuration to host
- `nixos-anywhere --flake .#HOSTNAME root@HOST_IP` - Remote deployment

## Architecture

### Directory Structure
- **flake.nix**: Main entry point using flake-parts
- **hosts/**: Individual machine configurations (Oxygen, Hydrogen, Lithium)
- **profiles/**: Reusable configuration modules organized by category
- **nix/**: Development tooling, modules, and build configuration

### Profile Categories
- `common/`: Base system configuration
- `graphical/`: Display, window managers (niri), fonts
- `apps/`: Application configurations
- `editors/`: Helix with language servers
- `terminal/`: Shell and terminal emulators (WezTerm, Ghostty)
- `networking/`: SSH, Tailscale, DNS configuration
- `security/`: GPG, secrets management
- `ai/`: Claude Code integration with custom home-manager module

## Key Technologies

### Build System
- **Nix Flakes**: Primary dependency and build management
- **flake-parts**: Modular flake organization
- **home-manager**: User environment configuration
- **just**: Command runner for common operations

### Development Tools
- **alejandra**: Nix formatter
- **statix**: Nix linter and static analysis
- **Helix**: Primary editor with LSP support for 10+ languages

## Secrets Management

All secrets are managed through an external private repository using:
- **sops-nix**: Encryption/decryption framework
- **Age encryption**: SSH-key-based encryption
- API keys (Anthropic, Atuin) stored encrypted per-host

## Impermanence Architecture

Root filesystem is wiped on reboot with selected directories persisted in `/persist/`:
- SSH keys: `/persist/etc/ssh/`
- User data and application state preserved selectively
- System designed for reproducible rebuilds

## Host Configurations

- **Oxygen**: Desktop/laptop with dual monitor setup
- **Hydrogen**: Desktop/laptop with temperature management
- **Lithium**: Live USB/bootstrap environment

## Testing & Quality

Run `nix flake check` before committing to validate:
- Nix syntax and evaluation
- statix linting rules
- System build verification

## CLAUDE.md Hierarchy

This project uses hierarchical context files for specialized documentation:

- `./CLAUDE.md` - Root context (this file)
- `./profiles/CLAUDE.md` - Profile system architecture and usage patterns
- `./profiles/graphical/CLAUDE.md` - Display, window managers, and hardware acceleration
- `./profiles/terminal/CLAUDE.md` - Shell, terminal emulators, and modern CLI tools
- `./profiles/ai/CLAUDE.md` - Claude Code integration with sandboxed execution
- `./hosts/CLAUDE.md` - Host-specific configurations and deployment workflows
- `./nix/CLAUDE.md` - Custom modules, development tooling, and build infrastructure

## Claude Code Integration

This repository includes a custom home-manager module for Claude Code with:
- Sandboxed execution via bubblewrap
- API key management through secrets
- Custom configuration in `profiles/ai/`