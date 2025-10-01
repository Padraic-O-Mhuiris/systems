{
  self,
  inputs,
  lib,
  ...
}: let
  eachSystem = lib.genAttrs (builtins.attrNames self.allSystems);
in {
  flake = {
    nixidyEnvs = eachSystem (system: let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in {
      local = inputs.nixidy.lib.mkEnv {
        inherit pkgs;
        modules = [
          ./demo
          ./l1

          # nixidy specific settings
          {
            nixidy = {
              target = {
                repository = "https://github.com/Padraic-O-Mhuiris/systems";
                branch = "master";
                rootPath = "./clusters/local/manifests";
              };
              build.revision =
                if (self ? rev)
                then self.rev
                else self.dirtyRev;
            };
          }
        ];
      };
    });
  };
}
