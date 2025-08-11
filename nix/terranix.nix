{inputs, ...}: {
  imports = [
    inputs.terranix.flakeModule
  ];
  perSystem = _: {
    terranix.exportDevShells = false;
  };
}
