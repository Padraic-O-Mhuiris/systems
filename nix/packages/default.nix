_: {
  perSystem =
    {
      config,
      self',
      inputs',
      pkgs,
      system,
      ...
    }:
    {
      packages.berkeley-mono = pkgs.callPackage ./berkeley-mono { };
    };
}
