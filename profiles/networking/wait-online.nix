{lib, ...}: {
  # https://github.com/NixOS/nixpkgs/issues/180175#issuecomment-1473408913
  # Helps during rebuild as `NetworkManager-wait-for-online` fails during rebuilds
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
}
