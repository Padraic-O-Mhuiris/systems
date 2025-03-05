_: {
  imports = [./bootstrap];
  perSystem = {pkgs, ...}: {
    packages = {
      berkeley-mono = pkgs.callPackage ./berkeley-mono {};
    };
  };
}
