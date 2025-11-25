{
  description = "NixOS systems configuration: multi-host setup with flake-parts, profiles, Kubernetes infrastructure, and secrets management";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    nixos-facter-modules = {
      url = "github:numtide/nixos-facter-modules";
    };

    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere/1.9.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devshell.url = "github:numtide/devshell";

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
    };

    nixidy = {
      url = "github:arnarg/nixidy";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "git+ssh://git@github.com/Padraic-O-Mhuiris/.secrets.git?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;}
    {
      debug = true;
      imports = [
        ./nix
        ./packages
        ./hosts
        ./infra
      ];
      systems = ["x86_64-linux"];
    };
}
