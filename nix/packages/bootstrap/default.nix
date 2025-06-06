{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    nixos-anywhere =
      inputs.nixos-anywhere.packages.${pkgs.system}.default;
  in {
    packages.bootstrap = pkgs.writeShellScriptBin "bootstrap" ''
      set -euo pipefail
      HOST=$1
      URL=$2
      PORT=$3

      usage() {
        echo "Usage: $0 --host <hostname> --url <ip|hostname> [--port <port>]"
        exit 1
      }

      PORT="22"

      # Parse arguments
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --host)
            HOST="$2"
            shift 2
            ;;
          --url)
            URL="$2"
            shift 2
            ;;
          --port)
            PORT="$2"
            shift 2
            ;;
          *)
            usage
            ;;
        esac
      done

      [[ -z "''${HOST:-}" || -z "''${URL:-}" ]] && usage

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

      chmod 0600 "$temp/persist/etc/ssh/ssh_host_ed25519_key"
      chmod 0644 "$temp/persist/etc/ssh/ssh_host_ed25519_key.pub"

      ${nixos-anywhere}/bin/nixos-anywhere \
        --extra-files "$temp" \
        --disk-encryption-keys /tmp/secret.key <(pass show systems/disks/$HOST) \
        --flake ".#$HOST" \
        --phases 'kexec,disko,install,reboot' \
        --ssh-port $PORT \
        --debug \
        $URL
    '';
  };
}
