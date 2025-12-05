{pkgs}:
pkgs.writeShellScriptBin "helium-destroy" ''
  set -euo pipefail
  echo "Destroy"
''
