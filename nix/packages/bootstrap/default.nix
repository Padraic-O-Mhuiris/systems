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

      ${pkgs.pass}/bin/pass show "systems/ssh/$HOST/ssh_host_ed25519_key.pub" > "$temp/persist/etc/ssh/ssh_host_ed25519_key.pub"
      ${pkgs.pass}/bin/pass show "systems/ssh/$HOST/ssh_host_ed25519_key" > "$temp/persist/etc/ssh/ssh_host_ed25519_key"

      ${nixos-anywhere}/bin/nixos-anywhere \
        --extra-files "$temp" \
        --disk-encryption-keys /tmp/secret.key <(pass show systems/disks/$HOST) \
        --flake ".#$HOST" \
        --phases 'kexec,disko,install,reboot' \
        $URL
    '';
  };
}
