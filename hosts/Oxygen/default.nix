{
  pkgs,
  vars,
  inputs,
  ...
}: {
  imports = [
    ./disk.nix
    inputs.secrets.nixosModules.default
  ];

  # Host-specific secrets configuration
  sops.secrets."${vars.PRIMARY_USER.NAME}_password" = {
    neededForUsers = true;
  };

  networking.networkmanager.ensureProfiles.profiles."home".ipv4.address = "192.168.0.50/24";

  # gnome-keyring can spawn popups on program launch like spotify.
  environment.variables.XDG_RUNTIME_DIR = "/run/user/${toString vars.PRIMARY_USER.UID}";
  environment.systemPackages = [pkgs.libsecret];

  home-manager.users.${vars.PRIMARY_USER.NAME} = {config, ...}: {
    imports = [
      inputs.secrets.homeModules.default
    ];
    sops.secrets = {
      atuin_session = {};
      atuin_key = {};
      anthropic_api_key = {};
    };
    programs.zsh.initContent = ''
      export ANTHROPIC_API_KEY="$(cat ${config.sops.secrets.anthropic_api_key.path})"
    '';
    programs.niri.settings = {
      cursor = {
        size = 24;
      };
      outputs = {
        "DP-1" = {
          enable = true;
          scale = 1.0;
          mode = {
            height = 1440;
            width = 5120;
            refresh = 59.977;
          };
          position = {
            x = 1920;
            y = 0;
          };
          focus-at-startup = true;
        };
        "HDMI-A-1" = {
          enable = true;
          scale = 1;
          mode = {
            height = 1080;
            width = 1920;
            refresh = 60.0;
          };
          position = {
            x = 0;
            y = 0;
          };
        };
      };
    };

    wayland.windowManager.hyprland.settings = {
      monitor = [
        "HDMI-A-1, 1920x1080@60, 0x0, 1"
        "DP-1, 5120x1440@60, 1920x0, 1"
      ];
    };
  };

  time.timeZone = "Europe/Dublin";

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";

  networking.hostName = "Oxygen";
}
