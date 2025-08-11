{inputs, ...}: {
  flake = {
    root = ../.;
  };
  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  };
  imports = [
    ./formatter.nix
    ./shell.nix
    ./packages
    ./lib
  ];
}
