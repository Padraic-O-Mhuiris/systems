{
  self,
  inputs,
  ...
}: let
  inherit (self) lib;

  root = ../.;

  specialArgs = {
    inherit inputs;
    inherit lib;
    inherit root;
  };

  common = [];
in {
  flake.nixosConfigurations = {
    Oxygen = lib.nixosSystem {
      inherit specialArgs;
      modules = [./Oxygen] ++ common;
    };
    Hydrogen = lib.nixosSystem {
      inherit specialArgs;
      modules = [./Hydrogen] ++ common;
    };
  };
}
