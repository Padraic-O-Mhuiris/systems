{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  networking = {
    hostName = "Helium";
    useDHCP = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [22 443 80];
      allowedUDPPorts = [51820]; # WireGuard
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # TODO: Configure headscale service
  # services.headscale = {
  #   enable = true;
  #   address = "0.0.0.0";
  #   port = 443;
  # };

  users.users.root.openssh.authorizedKeys.keys = [
    # Add SSH keys here or via secrets
  ];

  time.timeZone = "Europe/Dublin";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.05";
}
