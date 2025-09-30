# Graphical Environment Configuration

Configuration for display systems, window managers, and visual components across all graphical hosts.

## Architecture Overview

This profile manages the complete graphical stack:
- **Display management**: Session handling and display server startup
- **Window managers**: Primary (niri) and alternative (hyprland) configurations  
- **Hardware acceleration**: NVIDIA GPU support and driver management
- **Typography**: Font rendering and system fonts
- **Hardware monitoring**: Temperature management for mobile devices

## Window Manager Strategy

### Primary: Niri (`wm/niri/`)
Scrollable tiling Wayland compositor optimized for productivity:
- **Dynamic workspaces**: Horizontally scrolling workspace paradigm
- **Tiling behavior**: Automatic window arrangement with manual override
- **Multi-monitor**: Seamless workspace spanning across displays
- **Integration components**:
  - `waybar.nix` - Status bar with system metrics
  - `mako.nix` - Notification daemon
  - `swaylock.nix` - Screen locking
  - `wezterm-toggle.nix` - Terminal dropdown functionality

### Alternative: Hyprland (`wm/hyprland.nix`)
Feature-rich tiling Wayland compositor available as fallback option.

## Hardware Support

### NVIDIA Configuration (`nvidia.nix`)
Comprehensive NVIDIA driver setup:
- Proprietary driver installation and configuration
- Hardware acceleration for Wayland compositors
- Multi-GPU system support
- Power management integration

### Display Management (`displayManager.nix`)
Session and display server configuration:
- Login manager setup
- Session selection and startup
- Display server initialization
- Multi-user session handling

### Font System (`fonts.nix`)
Typography configuration:
- System font installation (Nerd Fonts, programming fonts)
- Font rendering configuration (subpixel rendering, hinting)
- Application-specific font overrides

## Temperature Management (`temperature.nix`)

Thermal monitoring and control for laptops:
- CPU temperature monitoring via sensors
- Thermal throttling configuration
- Fan curve management
- Battery thermal protection

## Module Integration

Graphical profiles integrate with:
- **Terminal profiles**: WezTerm/Ghostty configuration for Wayland
- **Application profiles**: GUI applications requiring Wayland support
- **Hardware profiles**: Monitor, keyboard, and peripheral configuration
- **Common profiles**: Base system requirements for graphical boot

## Host-Specific Considerations

### Desktop Systems (Oxygen, Hydrogen)
- Multi-monitor configurations
- High-performance graphics settings
- External display management

### Mobile Systems
- Power-efficient graphics configuration
- Thermal management priority
- Battery-aware display scaling

## Debugging and Troubleshooting

### Common Commands
```bash
# Check Wayland compositor status
systemctl --user status niri

# Monitor graphics performance
nvidia-smi  # NVIDIA systems
glxinfo | grep -i vendor

# Debug display configuration  
wlr-randr  # Wayland display management
```

### Log Locations
- Compositor logs: `journalctl --user -u niri`
- Display manager: `journalctl -u display-manager`
- Graphics driver: `journalctl -k | grep -i nvidia`