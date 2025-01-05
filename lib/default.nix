{ inputs, ... }:
let
  l = inputs.nixpkgs.lib.extend (
    _: lib: {

      log = expr: builtins.trace expr expr;
    }
  );
in
{
  _module.args = {
    inherit l;
  };

  flake = {
    inherit l;
  };
}
