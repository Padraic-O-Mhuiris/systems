# Hosts

Comprises multiple target host platforms

# Bootstrap

- Lithium

Lithium is a live-usb target which is used to connect to local wifi and enable a simplified nixos-anywhere installation.

# Personal Machines

- Hydrogen
- Oxygen

These machines are general-purpose, everyday, local devices which I use to control and manage the entire system.

## Deployment

On the target machine boot from the Lithium live usb and ensure an "ssh-able" connection is possible.

Run the bootstrap script which extracts the host and user ssh key-pairs and ports them to the new machine along with formatting the disk and installing the host image derivation.

```bash
nix run .\#packages.x86_64-linux.bootstrap -- --host <HOST> --url root@<IP>
```

This will setup the first environment for the machine which when complete will reboot. The correct state of the system requires the execution of the home-manager activation scripts which requires a subsequent rebuild of the system.

```bash
nixos-rebuild switch --flake .#<HOST_DERIVATION> --target-host <USER>@<TARGET_HOST> --build-host <USER>@<BUILD_HOST> --use-remote-sudo
```

## TODOs

- [] The tailscale initialisation doesn't work, may need a better approach to setup as the setup key is ephemeral
