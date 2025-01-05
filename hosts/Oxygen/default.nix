_: {
  imports = [ ./disk.nix ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "Oxygen";
}
