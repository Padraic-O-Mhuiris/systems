{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    inherit (import "${inputs.nixpkgs}/nixos/modules/misc/ids.nix" {lib = inputs.nixpkgs.lib;}.config.ids) gids;

    nixos-anywhere =
      inputs.nixos-anywhere.packages.${pkgs.system}.default;

    vars = inputs.secrets.vars;
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


      # We copy the ssh host key to the persist directory such that it will symlink to the /etc/ssh/ssh_host* files
      # It's also required that sops references /persist/etc/ssh/ in its `age.sshKeyPaths` configuration
      install -d -m755 "$temp/persist/etc/ssh"

      ${pkgs.pass}/bin/pass show "systems/ssh/$HOST/ssh_host_ed25519_key.pub" > "$temp/persist/etc/ssh/ssh_host_ed25519_key.pub"
      ${pkgs.pass}/bin/pass show "systems/ssh/$HOST/ssh_host_ed25519_key" > "$temp/persist/etc/ssh/ssh_host_ed25519_key"

      chmod 0600 "$temp/persist/etc/ssh/ssh_host_ed25519_key"
      chmod 0644 "$temp/persist/etc/ssh/ssh_host_ed25519_key.pub"


      install -d -m700 "$temp/home/${vars.PRIMARY_USER.NAME}/.ssh"

      chown ${vars.PRIMARY_USER.NAME}:users "$temp/home/${vars.PRIMARY_USER.NAME}"
      chown ${vars.PRIMARY_USER.NAME}:users "$temp/home/${vars.PRIMARY_USER.NAME}/.ssh"

      ${pkgs.pass}/bin/pass show "systems/users/${vars.PRIMARY_USER.NAME}/ssh/id_ed25519" > "$temp/home/${vars.PRIMARY_USER.NAME}/.ssh/id_ed25519"
      ${pkgs.pass}/bin/pass show "systems/users/${vars.PRIMARY_USER.NAME}/ssh/id_ed25519.pub" > "$temp/home/${vars.PRIMARY_USER.NAME}/.ssh/id_ed25519.pub"

      chmod 0600 "$temp/home/${vars.PRIMARY_USER.NAME}/.ssh/id_ed25519"
      chmod 0644 "$temp/home/${vars.PRIMARY_USER.NAME}/.ssh/id_ed25519.pub"

      ${nixos-anywhere}/bin/nixos-anywhere \
        --extra-files "$temp" \
        --disk-encryption-keys /tmp/secret.key <(pass show systems/disks/$HOST) \
        --flake ".#$HOST" \
        --phases 'kexec,disko,install,reboot' \
        --chown /home/${vars.PRIMARY_USER.NAME}/.ssh "${toString vars.PRIMARY_USER.UID}:${toString gids.users}" \
        --ssh-port $PORT \
        --debug \
        $URL
    '';
  };
}
