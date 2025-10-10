{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  nixpkgs = {
    config.allowUnfree = lib.mkDefault true;
  };

  environment.systemPackages = with pkgs; [nix-fast-build nix-eval-jobs];

  programs.nix-ld.enable = true;

  nix = {
    # pin the registry to avoid downloading and evaling a new nixpkgs version every time
    registry = lib.mapAttrs (_: v: {flake = v;}) inputs;
    package = pkgs.nixVersions.nix_2_30;

    # set the path for channels compat
    nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry;

    settings = {
      auto-optimise-store = true;
      builders-use-substitutes = true;
      experimental-features = ["nix-command" "flakes"];
      flake-registry = "/etc/nix/registry.json";

      http-connections = 256;
      max-jobs = "auto";
      warn-dirty = false;

      allow-import-from-derivation = true;

      keep-derivations = true;
      keep-outputs = true;

      trusted-users = ["root" "@wheel"];
      substituters = [
        "https://nix-community.cachix.org"
        "https://numtide.cachix.org"
        "https://cache.garnix.io" # Adding EU-based cache
        "https://cache.nixos.org" # Moved to last as fallback
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
  };
}
