{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    hcloud = pkgs.writeShellScriptBin "hcloud" ''
      set -euo pipefail
      export HCLOUD_TOKEN=$(${pkgs.pass}/bin/pass show systems/infra/neon/hcloud-token)
      exec ${pkgs.hcloud}/bin/hcloud "$@"
    '';
  in {
    packages.hcloud = hcloud;
  };
}
