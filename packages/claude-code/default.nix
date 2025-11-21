_: {
  perSystem = {pkgs, ...}: {
    packages.claude-code = pkgs.callPackage ./package.nix {};
  };
}
