{
  self,
  inputs,
  ...
}: let
  inherit (self) lib;

  specialArgs = {
    inherit inputs;
    inherit lib;
  };

  common = [];
in {
  flake.nixosConfigurations = {
    Oxygen = lib.nixosSystem {
      inherit specialArgs;
      modules = [./Oxygen] ++ common;
    };
  };
}
