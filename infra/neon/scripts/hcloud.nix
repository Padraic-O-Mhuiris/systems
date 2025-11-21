{
  pkgs,
  vars,
}:
pkgs.writeShellScriptBin "hcloud" ''
  set -euo pipefail
  export HCLOUD_TOKEN=$(${pkgs.pass}/bin/pass show ${vars.PASSWORD_STORE_PATH.HCLOUD_TOKEN})
  exec ${pkgs.hcloud}/bin/hcloud "$@"
''
