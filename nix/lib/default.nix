{inputs, ...}: {
  flake.lib = inputs.nixpkgs.lib.extend (_: lib: {});
}
