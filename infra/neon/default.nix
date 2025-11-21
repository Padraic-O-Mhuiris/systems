{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    vars = inputs.secrets.infra.neon.vars;

    hcloud = pkgs.writeShellScriptBin "hcloud" ''
      set -euo pipefail
      export HCLOUD_TOKEN=$(${pkgs.pass}/bin/pass show ${vars.PASSWORD_STORE_PATH.HCLOUD_TOKEN})
      exec ${pkgs.hcloud}/bin/hcloud "$@"
    '';

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
          nix run .#neon.hcloud  Hetzner Cloud CLI (with embedded API token)

        HELP
        EOF
        chmod +x $out/bin/neon
      '';

      passthru = {
        inherit hcloud;
      };
    };
  in {
    packages.neon = neon;
  };
}
