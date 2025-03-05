{inputs, ...}: let
  lib = inputs.nixpkgs.lib.extend (_: lib: {});
in {
  _module.args = {
    inherit lib;
  };

  flake = {
    inherit lib;
  };
}
