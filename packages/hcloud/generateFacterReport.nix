{
  pkgs,
  vars,
  hcloud,
}:
pkgs.writeShellApplication {
  name = "generateFacterReport";
  runtimeInputs = [hcloud] ++ (with pkgs; [jq openssh]);
  text = ''
    set -euo pipefail

    if [ $# -ne 1 ]; then
      echo "Usage: generateFacterReport <server-type>"
      echo "Example: generateFacterReport cax11"
      exit 1
    fi

    SERVER_TYPE=$1
    TEMP_SERVER_NAME="facter-probe-$$"
    LOCATION="fsn1"
    IMAGE="ubuntu-24.04"
    OUTPUT_FILE="$SERVER_TYPE.json"

    SSH_KEY_NAME="neon-primary"
    SSH_PUBLIC_KEY="${vars.pubkeys.ssh.primary}"

    cleanup() {
      if [ -n "''${TEMP_SERVER_NAME:-}" ]; then
        echo "Cleaning up: Deleting temporary server $TEMP_SERVER_NAME..."
        hcloud server delete "$TEMP_SERVER_NAME" 2>/dev/null || true
      fi
    }

    trap cleanup EXIT

    echo "Ensuring SSH key is uploaded to Hetzner..."
    hcloud ssh-key create --name "$SSH_KEY_NAME" --public-key "$SSH_PUBLIC_KEY" 2>/dev/null || echo "SSH key already exists"

    # Get all SSH key IDs to add to server
    SSH_KEY_IDS=$(hcloud ssh-key list -o noheader -o columns=id | tr '\n' ',' | sed 's/,$//')

    echo "Creating temporary server: $TEMP_SERVER_NAME ($SERVER_TYPE)..."
    SERVER_INFO=$(hcloud server create \
      --name "$TEMP_SERVER_NAME" \
      --type "$SERVER_TYPE" \
      --location "$LOCATION" \
      --image "$IMAGE" \
      --ssh-key "$SSH_KEY_IDS" \
      --output json)

    SERVER_IP=$(echo "$SERVER_INFO" | jq -r '.server.public_net.ipv4.ip')

    echo "Server created with IP: $SERVER_IP"
    echo "Waiting for SSH to be ready..."

    for _ in {1..30}; do
      if ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 root@"$SERVER_IP" "echo ready" 2>/dev/null; then
        break
      fi
      sleep 2
    done

    echo "Installing Nix..."
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@"$SERVER_IP" "curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes"

    echo "Running nixos-facter..."
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@"$SERVER_IP" ". /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh && nix run \
      --option experimental-features 'nix-command flakes' \
      --option extra-substituters https://numtide.cachix.org \
      --option extra-trusted-public-keys numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE= \
      github:nix-community/nixos-facter -- -o /tmp/facter.json && cat /tmp/facter.json" > "$OUTPUT_FILE"

    echo "Hardware report saved to $OUTPUT_FILE"
  '';
}
