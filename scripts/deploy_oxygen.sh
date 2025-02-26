#!/usr/bin/env bash

temp=$(mktemp -d)

# Function to cleanup temporary directory on exit
cleanup() {
  rm -rf "$temp"
}
trap cleanup EXIT

install -d -m755 "$temp/etc/ssh"

pass show os/hosts/Oxygen/ssh_host_ed25519_key.pub > "$temp/etc/ssh/ssh_host_ed25519_key.pub"
pass show os/hosts/Oxygen/ssh_host_ed25519_key > "$temp/etc/ssh/ssh_host_ed25519_key"

nixos-anywhere \
  --extra-files "$temp" \
  --disk-encryption-keys /tmp/secret.key <(pass show os/hosts/Oxygen/disk) \
  --flake '.#Oxygen' \
  --phases 'kexec,disko,install,reboot' \
  root@192.168.0.158

