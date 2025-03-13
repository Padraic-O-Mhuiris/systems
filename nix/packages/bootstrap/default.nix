{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    nixos-anywhere =
      inputs.nixos-anywhere.packages.${pkgs.system}.default;
  in {
    packages.bootstrap = pkgs.writeShellScriptBin "bootstrap" ''
      HOST=$1
      URL=$2

      temp=$(mktemp -d)

      cleanup() {
        rm -rf "$temp"
      }
      trap cleanup EXIT

      install -d -m755 "$temp/persist/etc/ssh"

      # We copy the ssh host key to the persist directory such that it will symlink to the /etc/ssh/ssh_host* files
      # It's also required that sops references /persist/etc/ssh/ in its `age.sshKeyPaths` configuration
      ${pkgs.pass}/bin/pass show "systems/ssh/$HOST/ssh_host_ed25519_key.pub" > "$temp/persist/etc/ssh/ssh_host_ed25519_key.pub"
      ${pkgs.pass}/bin/pass show "systems/ssh/$HOST/ssh_host_ed25519_key" > "$temp/persist/etc/ssh/ssh_host_ed25519_key"

      ${nixos-anywhere}/bin/nixos-anywhere \
        --extra-files "$temp" \
        --disk-encryption-keys /tmp/secret.key <(pass show systems/disks/$HOST) \
        --flake ".#$HOST" \
        --phases 'kexec,disko,install,reboot' \
        --debug \
        $URL
    '';
  };
}
