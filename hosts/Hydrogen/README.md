# Hydrogen

Personal desktop/laptop machine with full NixOS configuration.

## Hardware Configuration

- **Platform**: x86_64-linux
- **Display**: 3840x2400 @ 59.994Hz (eDP-1, scaled 1.75x)
- **Storage**: NVMe SSD with LUKS encryption
- **Network**: Static IP 192.168.0.51/24 (home profile)

## System Architecture

### Storage Layout (Disko)
- **Boot**: 500M VFAT partition on /boot
- **Encryption**: LUKS with LVM on remaining space
- **Volumes**:
  - `/persist` - 10G ext4 (persistent data)
  - `swap` - 16G encrypted swap
  - `/home` - 300G ext4 (user data)
  - `/nix` - remaining space ext4 (Nix store)
  - `/` - 2G tmpfs (ephemeral root)

### Key Features
- **Impermanence**: Root filesystem wiped on boot
- **Niri**: Wayland compositor with custom cursor settings
- **Timezone**: Europe/Dublin

## History

- Initial configuration established with disko disk management
- Configured for impermanence setup with persistent data on `/persist`
- Display scaling optimized for high-DPI screen

## Future Plans

- TBD based on usage patterns and requirements