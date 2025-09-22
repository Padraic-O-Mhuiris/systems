# Oxygen

Personal desktop/laptop machine with full NixOS configuration and dual-monitor setup.

## Hardware Configuration

- **Platform**: x86_64-linux
- **Network**: Static IP 192.168.0.50/24 (home profile)
- **Storage**: Dual SSD setup with LUKS encryption
  - Samsung SSD 970 EVO Plus 2TB (NVMe)
  - Samsung SSD 860 EVO 2TB (SATA)

## Display Configuration

### Monitor Setup
- **Primary**: DP-1 - 5120x1440 @ 59.977Hz (positioned at 1920,0, focus at startup)
- **Secondary**: HDMI-A-1 - 1920x1080 @ 60Hz (positioned at 0,0)
- **Total workspace**: 7040x1440 (ultrawide + standard monitor)

### Window Managers
- **Niri**: Cursor size 24, dual output configuration
- **Hyprland**: Alternative WM with same monitor layout

## System Architecture

### Storage Layout (Disko)
- **Boot**: 500M VFAT partition on NVMe
- **Encryption**: LUKS with LVM on both drives
- **Volume Distribution**:
  - **NVMe (vg-nvme)**: `/persist` (10G), `swap` (16G), `/home` (remaining)
  - **SATA (vg-sda)**: `/nix` (full drive)
  - **Root**: 2G tmpfs (ephemeral)

### Key Features
- **Impermanence**: Root filesystem wiped on boot
- **Dual storage**: Fast NVMe for user data, dedicated SATA for Nix store
- **Security**: libsecret integration, gnome-keyring support
- **Timezone**: Europe/Dublin

## History

- Configured with dual-SSD setup for performance optimization
- Display scaling and positioning tuned for productivity workflow
- Multiple window manager support (Niri/Hyprland)

## Future Plans

- TBD based on usage patterns and requirements