{vars, ...}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {pkgs, ...}: {
    home.packages = [pkgs.spotify];
  };

  networking.firewall = {
    allowedTCPPorts = [57621];
    allowedUDPPorts = [5353];
  };
}
