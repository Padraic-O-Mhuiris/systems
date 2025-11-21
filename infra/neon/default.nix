{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    vars = inputs.secrets.infra.neon.vars;

    hcloud = import ./scripts/hcloud.nix {
      inherit pkgs vars;
    };

    generateFacterReport = import ./scripts/generateFacterReport.nix {
      inherit pkgs vars hcloud;
      secrets = inputs.secrets.vars;
    };

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

        Available commands:
          nix run .#neon.hcloud                 Hetzner Cloud CLI (with embedded API token)
          nix run .#neon.generateFacterReport   Generate hardware config from temporary VPS

        HELP
        EOF
        chmod +x $out/bin/neon
      '';

      passthru = {
        inherit hcloud generateFacterReport;
      };
    };
  in {
    packages.neon = neon;
  };
}
