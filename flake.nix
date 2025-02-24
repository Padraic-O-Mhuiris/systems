{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    nixos-facter-modules = {
      url = "github:numtide/nixos-facter-modules";
    };

    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
    };

    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./nix
        ./iso
        ./lib
        ./vms
      ];
      systems = ["x86_64-linux"];
    };
}
