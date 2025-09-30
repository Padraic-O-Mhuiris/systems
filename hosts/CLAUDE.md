# Host Configurations

Host-specific NixOS configurations for individual machines. Each host directory contains the complete system definition for that machine, importing relevant profiles and defining hardware-specific settings.

## Host Architecture

### Directory Structure
Each host follows a consistent pattern:
```
HostName/
├── default.nix    # Main configuration entry point
├── disk.nix       # Disk partitioning and filesystem setup (if present)
├── facter.json    # Hardware detection results (if present)  
└── README.md      # Host-specific documentation
```

### Configuration Layers
1. **Hardware detection**: Automatic via facter.json
2. **Host-specific config**: Machine-specific settings in default.nix
3. **Profile imports**: Reusable configuration modules from ../profiles/
4. **Secrets**: Per-host encrypted configuration via external repository

## Current Hosts

### Oxygen
**Role**: Primary desktop/laptop with dual monitor setup
- **Profile mix**: Full graphical + development + AI tools
- **Hardware**: NVIDIA graphics, dual monitors, high-performance
- **Disk config**: Custom partitioning with impermanence setup
- **Special features**: GPU acceleration, multi-display management

### Hydrogen  
**Role**: Desktop/laptop with thermal management focus
- **Profile mix**: Graphical + development with temperature monitoring
- **Hardware**: Temperature-sensitive system requiring thermal management
- **Disk config**: Standard partitioning with persistence
- **Special features**: Advanced thermal monitoring and fan control

### Lithium
**Role**: Live USB/bootstrap environment
- **Profile mix**: Minimal system for installation and rescue
- **Hardware**: Generic hardware compatibility
- **Disk config**: Live system - no persistent storage
- **Special features**: Installation tooling, hardware detection

## Host Configuration Pattern

### Standard Import Structure
```nix
# hosts/HostName/default.nix
{
  imports = [
    # Hardware-specific
    ./disk.nix                    # If custom disk setup needed
    ../../profiles/common         # Always required base
    
    # Capability profiles  
    ../../profiles/graphical      # GUI systems
    ../../profiles/terminal       # All hosts need terminal
    ../../profiles/networking/tailscale.nix  # Mesh networking
    
    # Specific tools
    ../../profiles/ai             # Claude Code integration
    ../../profiles/editors        # Development tools
  ];

  # Host-specific overrides
  networking.hostName = "HostName";
  system.stateVersion = "24.05";
}
```

### Hardware Detection Integration
Facter provides automatic hardware detection:
- **facter.json**: Generated hardware profile
- **Boot configuration**: Automatic kernel module loading
- **Graphics drivers**: Automatic driver selection
- **Network interfaces**: Interface detection and naming

## Secrets Per Host

Each host has encrypted secrets managed externally:
- **API keys**: Anthropic, Atuin, service tokens
- **SSH keys**: Host-specific SSH configuration  
- **Certificates**: TLS certificates and signing keys
- **Network credentials**: WiFi passwords, VPN configurations

Access via: `sops secrets/hosts/HostName/secrets.yaml`

## Host-Specific Customization

### Hardware Overrides
```nix
# Example hardware-specific configuration
hardware.nvidia.enable = true;           # NVIDIA systems
hardware.bluetooth.enable = false;       # Disable if not needed
services.thermald.enable = true;         # Thermal management
```

### Network Configuration
```nix
# Host-specific networking
networking = {
  hostName = "HostName";
  interfaces.eth0.useDHCP = true;
  wireless.interfaces = [ "wlan0" ];
};
```

### Service Variations
```nix
# Host-specific services
services = {
  printing.enable = false;        # Disable on headless hosts
  xserver.videoDrivers = ["nvidia"];  # GPU-specific drivers
};
```

## Deployment Workflows

### Local Deployment
```bash
# From host machine
nixos-rebuild switch --flake .#HostName

# Test configuration
nixos-rebuild test --flake .#HostName
```

### Remote Deployment  
```bash
# Initial deployment to new hardware
nixos-anywhere --flake .#HostName root@HOST_IP

# Update existing remote host
nixos-rebuild switch --flake .#HostName --target-host root@HOST_IP
```

### Live USB Deployment
```bash
# Build Lithium ISO
nix build .#nixosConfigurations.Lithium.config.system.build.isoImage

# Flash to USB
dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress
```

## Adding New Hosts

1. **Create host directory**: `mkdir hosts/NewHost`
2. **Generate hardware config**: Run `nixos-generate-config` on target hardware
3. **Create default.nix**: Import appropriate profiles
4. **Add to flake.nix**: Register host in nixosConfigurations
5. **Configure secrets**: Add host-specific encrypted secrets
6. **Test deployment**: Use `nixos-rebuild test` before switching