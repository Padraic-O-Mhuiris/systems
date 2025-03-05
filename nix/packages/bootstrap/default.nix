{
  inputs,
  self,
  ...
}: let
  inherit (self) lib;
in {
  perSystem = {pkgs, ...}: let
    nixos-anywhere =
      inputs.nixos-anywhere.packages.${pkgs.system}.default;
  in {
    packages = lib.mapByHostName (host: {
      "bootstrap-${host}" = pkgs.writeShellScriptBin "" ''

        temp=$(mktemp -d)

        cleanup() {
          rm -rf "$temp"
        }
        trap cleanup EXIT

        install -d -m755 "$temp/etc/ssh"

        ${pkgs.pass}/bin/pass show systems/ssh/${host}/ssh_host_ed25519_key.pub > "$temp/etc/ssh/ssh_host_ed25519_key.pub"
        ${pkgs.pass}/bin/pass show systems/ssh/${host}/ssh_host_ed25519_key > "$temp/etc/ssh/ssh_host_ed25519_key"

        ${nixos-anywhere} \
          --extra-files "$temp" \
          --disk-encryption-keys /tmp/secret.key <(pass show systems/disk/${host}) \
          --flake '.#${host}' \
          --phases 'kexec,disko,install,reboot' \
          root@${inputs.secrets.vars.HOSTS."${host}".LOCAL_IP}
      '';
    });
  };
}
