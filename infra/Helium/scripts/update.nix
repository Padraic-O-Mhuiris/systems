{pkgs}:
pkgs.writeShellScriptBin "helium-update" ''
  set -euo pipefail
  echo "Update"
''
