{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    neon = pkgs.stdenv.mkDerivation {
      pname = "neon";
      version = "0.1.0";

      dontUnpack = true;

      installPhase = ''
        mkdir -p $out/bin
        cat > $out/bin/neon <<'EOF'
        #!/usr/bin/env bash
        set -euo pipefail
        cat <<HELP
        Neon - Personal VPC + Kubernetes Cluster

        Infrastructure tools:

        HELP
        EOF
        chmod +x $out/bin/neon
      '';
    };
  in {
    packages.neon = neon;
  };
}
