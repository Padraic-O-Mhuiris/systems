{
  pkgs,
  vars,
}:
pkgs.writeShellScriptBin "hcloud" ''
  set -euo pipefail
  export HCLOUD_TOKEN=$(${pkgs.pass}/bin/pass show ${vars.secrets.pass.hetznerCloudApiToken})
  exec ${pkgs.hcloud}/bin/hcloud "$@"
''
