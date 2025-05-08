{
  inputs,
  self,
  ...
}: {
  flake.lib = inputs.nixpkgs.lib.extend (_: lib: let
    inherit (lib) map attrsToList;
  in {
    mapByHostName = fn: (map fn (map ({name, ...}: name) (attrsToList self.nixosConfigurations)));

    # facter specific logic
    facter = import ./facter.nix {inherit lib;};
  });
}
