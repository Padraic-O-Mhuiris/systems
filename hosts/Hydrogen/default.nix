{vars, ...}: {
  imports = [
    ./disk.nix
    # ../../modules/terminal/shell/atuin.nix
  ];

  networking.networkmanager.ensureProfiles.profiles."home".ipv4.address = "192.168.0.51/24";

  home-manager.users.${vars.PRIMARY_USER.NAME} = _: {
    programs.niri.settings = {
      outputs = {};
    };
  };

  time.timeZone = "Europe/Dublin";

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";

  networking.hostName = "Hydrogen";
}
