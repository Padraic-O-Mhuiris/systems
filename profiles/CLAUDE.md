# NixOS Configuration Profiles

This directory contains reusable configuration modules organized by functional category. Each profile can be imported by host configurations to compose system capabilities.

## Profile Architecture

Profiles follow a consistent pattern:
- **Single-concern modules**: Each `.nix` file handles one specific capability
- **Composable imports**: Profiles can depend on other profiles
- **Host-agnostic**: Configuration that works across all machines
- **Declarative options**: Exposed via NixOS/home-manager module system

## Profile Categories

### Core System (`common/`)
Base system configuration required by all hosts:
- Boot configuration and kernel parameters
- Nix daemon settings and flake configuration
- Home-manager integration
- Package management and overlays
- Hardware detection via facter

### User Interface (`graphical/`)
Display and window management:
- Display managers and session configuration
- Window managers (niri primary, hyprland available)
- Font configuration and rendering
- Hardware acceleration (NVIDIA support)
- Temperature monitoring for laptops

### Applications (`apps/`)
Application-specific configurations:
- Browser setup (Firefox, Zen)
- Communication tools (Slack, Telegram)
- Media applications (Spotify)
- Office and productivity tools

### Development (`editors/`)
Development environment configuration:
- Git configuration with signing
- Helix editor with LSP support for 10+ languages
- Language-specific tooling and formatters

### Terminal Environment (`terminal/`)
Shell and terminal emulator setup:
- Shell configuration (zsh with oh-my-zsh)
- Terminal emulators (WezTerm, Ghostty)
- Command history via Atuin
- Modern CLI tool aliases

### Network Services (`networking/`)
Network configuration and services:
- SSH client/server configuration
- Tailscale mesh networking
- DNS configuration
- Firewall rules
- WiFi and connectivity

### Security (`security/`)
Security and authentication:
- GPG configuration for signing
- Sudo configuration
- Hardware security modules

### Hardware Support (`peripherals/`)
Hardware-specific configuration:
- Audio (PipeWire/PulseAudio)
- Bluetooth connectivity
- Keyboard and input devices
- Monitor configuration
- USB device handling

### AI Tools (`ai/`)
Claude Code integration with sandboxed execution - see `ai/CLAUDE.md` for details.

## Profile Usage Patterns

### In Host Configurations
```nix
# hosts/Oxygen/default.nix
imports = [
  ../../profiles/common
  ../../profiles/graphical
  ../../profiles/terminal
  ../../profiles/networking/tailscale.nix
];
```

### Profile Dependencies
Profiles may import related profiles:
```nix
# profiles/graphical/default.nix  
imports = [
  ../common  # Always requires base system
];
```

## Naming Conventions

- **Directories** for multi-file profiles with complex configuration
- **Single .nix files** for simple, self-contained modules
- **default.nix** in directories acts as the main entry point
- **CamelCase** for profile directory names matching their functional domain

## Development Guidelines

When creating new profiles:
1. Keep configuration **host-agnostic** - use NixOS options for host-specific values
2. **Document dependencies** - clearly specify required base profiles
3. **Expose options** where configuration varies between use cases
4. **Test across hosts** - ensure portability between machines
5. **Single responsibility** - one profile per logical capability