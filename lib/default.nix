{ inputs, self, ... }:
let
  l = inputs.nixpkgs.lib.extend (
    _: lib: {

      log = expr: builtins.trace expr expr;

      mkNixosSystem =
        modules:
        let
          specialArgs = {
            inherit inputs;
            inherit l;
            inherit self;
          };
        in
        lib.nixosSystem {
          inherit specialArgs;
          inherit modules;
        };
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
