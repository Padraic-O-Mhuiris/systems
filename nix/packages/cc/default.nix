_: {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages.cc = pkgs.callPackage ./cc.nix {
      claude = self'.packages.claude-code;
    };
  };
}
