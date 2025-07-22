{
  inputs,
  vars,
  ...
}: {
  imports = [
    inputs.secrets.nixosModules.wifi-home
    ./disk.nix
    # ../../modules/terminal/shell/atuin.nix
  ];

  networking.networkmanager.ensureProfiles.profiles."home".ipv4.address = "192.168.0.51/24";

  home-manager.users.${vars.PRIMARY_USER.NAME} = _: {
    programs.niri.settings = {
      outputs = {
        #   "DP-1" = {
        #     enable = true;
        #     scale = 1.0;
        #     mode = {
        #       height = 1440;
        #       width = 5120;
        #       refresh = 59.977;
        #     };
        #     position = {
        #       x = 1920;
        #       y = 0;
        #     };
        #     focus-at-startup = true;
        #   };
        #   "HDMI-A-1" = {
        #     enable = true;
        #     scale = 1;
        #     mode = {
        #       height = 1080;
        #       width = 1920;
        #       refresh = 60.0;
        #     };
        #     position = {
        #       x = 0;
        #       y = 0;
        #     };
        #   };
        # };
      };

      # wayland.windowManager.hyprland.settings = {
      #   monitor = [
      #     "HDMI-A-1, 1920x1080@60, 0x0, 1"
      #     "DP-1, 5120x1440@60, 1920x0, 1"
      #   ];
      # };
    };
  };

  time.timeZone = "Europe/Dublin";

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";

  networking.hostName = "Hydrogen";
}
