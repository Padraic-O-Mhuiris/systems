{
  inputs,
  self,
  ...
}: {
  flake.lib = inputs.nixpkgs.lib.extend (_: lib: let
    inherit (lib) map attrsToList;
  in {
    mapByHostName = fn: (map ({name, ...}: name) (attrsToList self.nixosConfigurations));
  });
}
