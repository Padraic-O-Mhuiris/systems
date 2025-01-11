{ self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        berkeley-mono = pkgs.callPackage ./berkeley-mono { };
        HeliumVM = self.vms.Helium.config.microvm.declaredRunner;
      };
    };
}
