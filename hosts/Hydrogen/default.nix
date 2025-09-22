{vars, inputs, config, ...}: {
  imports = [
    ./disk.nix
    inputs.secrets.nixosModules.default
  ];

  # Host-specific secrets configuration
  sops.secrets."${vars.PRIMARY_USER.NAME}_password" = {
    neededForUsers = true;
  };

  networking.networkmanager.ensureProfiles.profiles."home".ipv4.address = "192.168.0.51/24";

  home-manager.users.${vars.PRIMARY_USER.NAME} = _: {
    imports = [
      inputs.secrets.homeModules.default
    ];
    sops.secrets = {
      atuin_session = {};
      atuin_key = {};
    };
    programs.niri.settings = {
      cursor = {
        size = 36;
      };
      outputs = {
        "eDP-1" = {
          enable = true;
          scale = 1.75;
          mode = {
            height = 2400;
            width = 3840;
            refresh = 59.994;
          };
        };
      };
    };
  };

  time.timeZone = "Europe/Dublin";

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";

  networking.hostName = "Hydrogen";
}
