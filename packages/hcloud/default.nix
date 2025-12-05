{inputs, ...}: let
  inherit (inputs.secrets) vars;
in {
  perSystem = {pkgs, ...}: let
    wrapper = import ./wrapper.nix {
      inherit pkgs vars;
    };

    generateFacterReport = import ./generateFacterReport.nix {
      inherit pkgs vars;
      hcloud = wrapper;
    };

    hcloud = pkgs.stdenv.mkDerivation {
      pname = "hcloud";
      version = "0.1.0";

      dontUnpack = true;

      installPhase = ''
        mkdir -p $out/bin
        ln -s ${wrapper}/bin/hcloud $out/bin/hcloud
      '';

      passthru = {
        inherit generateFacterReport;
      };
    };
  in {
    packages.hcloud = hcloud;
  };
}
