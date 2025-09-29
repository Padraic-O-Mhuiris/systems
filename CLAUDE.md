# CLAUDE.md

This file provides guidance to Claude Code when working with this NixOS configuration repository.

## Project Overview

This is a mature, principal-level NixOS configuration repository demonstrating exceptional engineering practices. The system manages personal NixOS installations across multiple machines using a sophisticated modular architecture with flakes, featuring comprehensive automation, robust security, and scalable design patterns.

### Architecture Highlights
- **Modular Design**: Clean separation of concerns with logical categorization (ai/, graphical/, networking/, etc.)
- **Host Abstraction**: Elegant host configuration pattern enabling easy machine onboarding
- **Security-First**: Impermanence strategy, comprehensive secrets management, and hardened configurations
- **Automation Excellence**: Fully automated deployment pipeline with nixos-anywhere integration

## Build System and Commands

### Development Workflow
- `nix develop` - Enter development shell with alejandra, git, hcloud, just, nixos-anywhere, terranix
- `nix fmt` - Format Nix files using alejandra formatter
- `nix flake check` - Validate flake configuration and build outputs
- `just update-secrets` - Update secrets flake input and commit changes (equivalent to manual flake update + git commit)

### Flake Management
- `nix flake update` - Update all flake inputs
- `nix flake update secrets` - Update only the secrets input

### Host Building and Deployment
- `nix build .#nixosConfigurations.<HOST>.config.system.build.toplevel` - Build host configuration
- `nix run .#packages.x86_64-linux.bootstrap -- --host <HOST> --url root@<IP>` - Bootstrap new installation
- `nixos-rebuild switch --flake .#<HOST_DERIVATION> --target-host <USER>@<TARGET_HOST> --build-host <USER>@<BUILD_HOST> --use-remote-sudo` - Remote rebuild

### Live USB and Installation
- `nix build .#packages.x86_64-linux.Lithium` - Build Lithium live USB ISO image

## Architecture

### Core Structure
- **flake.nix**: Main entry point using flake-parts for composable configuration
- **hosts/**: Machine-specific configurations with shared abstraction layer
- **modules/**: Categorized reusable NixOS modules with clean interfaces
- **nix/**: Build system, packages, and development utilities
- **docs/**: Comprehensive documentation including security practices

### Host Ecosystem
- **Lithium**: Live USB/bootstrap environment for installations
- **Hydrogen/Oxygen**: Personal desktop/laptop configurations
- **Carbon**: Server/infrastructure host (deployment in progress)

### Module Categories
- **ai/**: AI tools and services (claude-code, agents)
- **apps/**: Application configurations (browsers, productivity)
- **common/**: Core system foundation (nix, boot, secrets, impermanence)
- **editors/**: Development environment (git, helix)
- **graphical/**: Display systems (niri compositor, nvidia, fonts)
- **networking/**: Network services (SSH, tailscale, DNS, firewall)
- **peripherals/**: Hardware support (audio, bluetooth, monitors)
- **security/**: Security hardening and access control
- **services/**: System services and daemons
- **terminal/**: Terminal environments (wezterm, ghostty, zsh)
- **users/**: User account and home-manager integration

### Key Technologies
- **nixos-anywhere**: Automated remote installation system
- **disko**: Declarative disk partitioning and formatting
- **home-manager**: User environment management
- **impermanence**: Stateless system with selective persistence
- **sops-nix**: Encrypted secrets management
- **niri**: Modern Wayland compositor
- **Pass**: Password store for bootstrap secrets

### Security Architecture
- **Impermanence Strategy**: Ephemeral root filesystem with `/persist/` for critical data
- **Secrets Management**: Private flake integration with sops encryption
- **Key Management**: SSH keys via pass, age keys in `/persist/etc/ssh/`
- **Bootstrap Security**: Automated secure key deployment during installation

## Engineering Standards

### Code Quality
- Consistent Nix code style and conventions
- Modular design with clear interfaces
- Comprehensive error handling in automation
- Type safety where applicable

### Documentation Standards
- Inline documentation for complex expressions
- Architectural decision records in relevant modules
- Comprehensive secrets management documentation
- Troubleshooting guides for common scenarios

### Testing Approach
- Configuration validation through nix flake check
- Integration testing for deployment scenarios
- Smoke tests for critical services (recommended enhancement)

## Commit Guidelines

- Use concise, descriptive messages summarizing changes
- NO co-author attributions or AI tool references
- Follow existing repository commit message patterns
- Group related changes into logical commits
- Make incremental commits as work progresses

## Collaboration Workflow

### Task Approach
- **Small changes**: Direct implementation without extensive planning
- **Complex projects**: Use TodoWrite tool for planning and progress tracking
- **Architectural changes**: Present suggestions and await guidance
- **When uncertain**: Always clarify scope before implementation

### Enhancement Priorities
1. **Documentation**: Inline code docs, troubleshooting guides
2. **Testing**: Validation tests, integration testing
3. **Monitoring**: System health, configuration drift detection
4. **Refinements**: Common patterns extraction, naming standardization

## Context Management

This CLAUDE.md should be updated with:
- Current focus areas and project priorities
- Architectural decisions and discovered patterns
- Evolution of build/deployment procedures
- Workflow patterns and collaboration preferences
- Status of ongoing projects (Carbon deployment, AI integration)

Use host-specific README.md files for detailed project context and planning.

## Project Status

**Maturity Level**: Production-ready with continuous enhancement
**Architecture Quality**: Principal-level engineering practices
**Security Posture**: Comprehensive and well-documented
**Automation Coverage**: Fully automated deployment and management
**Documentation**: Strong foundation with enhancement opportunities
**Technical Debt**: Minimal, well-maintained codebase