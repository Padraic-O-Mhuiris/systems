_: {
  perSystem = {pkgs, ...}: {
    packages = {
      berkeley-mono = pkgs.callPackage ./berkeley-mono {};
    };
  };
}
