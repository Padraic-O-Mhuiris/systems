_: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    create = import ./scripts/create.nix {inherit pkgs;};
    update = import ./scripts/update.nix {inherit pkgs;};
    destroy = import ./scripts/destroy.nix {inherit pkgs;};

    helium = pkgs.stdenv.mkDerivation {
      pname = "helium";
      version = "0.1.0";
      dontUnpack = true;

      installPhase = ''
        mkdir -p $out/bin
        cat > $out/bin/helium <<'EOF'
        #!/usr/bin/env bash
        cat <<HELP
        Helium - Headscale VPN Server

        Infrastructure commands (via nix run .#Helium.<cmd>):
          create   - Create Hetzner server
          update   - Update NixOS configuration
          destroy  - Delete server (with confirmation)

        HELP
        EOF
        chmod +x $out/bin/helium
      '';

      passthru = {
        inherit create update destroy;
      };
    };
  in {
    packages.Helium = helium;
  };
}
