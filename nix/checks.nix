_: {
  perSystem = {pkgs, ...}: {
    checks = {
      statix = pkgs.runCommand "statix-check" {
        nativeBuildInputs = [pkgs.statix];
      } ''
        cd ${../.}
        statix check .
        touch $out
      '';
    };
  };
}