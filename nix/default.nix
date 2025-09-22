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
    ./checks.nix
    ./shell.nix
    ./packages
    ./lib
  ];
}
