# Lithium

Live USB/bootstrap environment for new NixOS installations and system recovery.

## Purpose

Installation and recovery ISO image based on NixOS minimal installation CD with custom configurations for bootstrapping new systems.

## Configuration

### Base System
- **Platform**: x86_64-linux (default)
- **Kernel**: Latest Linux kernel packages
- **Network**: Static IP 192.168.0.52/24 (home profile)
- **Timezone**: Europe/Dublin

### Hardware Support
- **Firmware**: All firmware enabled (including redistributable)
- **Bluetooth**: Disabled for minimal footprint
- **Wireless**: Comprehensive driver support including:
  - Broadcom (brcmfmac, brcmutil)
  - Intel WiFi (iwlmvm, iwlwifi)
  - MediaTek USB (mt76 series)
  - Realtek (rtl8192cu, r8188eu)

### Filesystem Support
- btrfs, reiserfs, vfat, f2fs, xfs, ntfs, cifs
- Focused on common installation and recovery scenarios

### Security & Access
- **SSH**: Enabled by default
- **Root access**: Configured SSH key for remote bootstrap
- **Sudo**: Passwordless for wheel group
- **Auto-login**: Root user for console access

### Tools Included
- vim, htop, git, rsync
- Essential utilities for system installation and configuration

## Usage

### Building ISO
```bash
nix build .#packages.x86_64-linux.Lithium
```

### Bootstrap Workflow
1. Boot from Lithium ISO on target machine
2. Network configuration automatically applied
3. SSH access available for remote installation
4. Use with nixos-anywhere for automated deployments

## History

- Created as minimal installation environment
- Optimized for remote bootstrap scenarios
- Integrated with secrets flake for WiFi credentials

## Future Plans

- Additional recovery tools as needed
- Hardware-specific driver additions for new systems