{vars, ...}: {
  imports = [
    ./disk.nix

    ../../modules/common/home-manager.nix
    ../../modules/common/nix
    ../../modules/common/facter.nix
    ../../modules/common/boot.nix
    ../../modules/common/login.nix
    ../../modules/common/secrets.nix
    ../../modules/common/pkgs.nix
    ../../modules/common/impermanence.nix

    ../../modules/networking/wifi.nix
    ../../modules/networking/ssh.nix
    ../../modules/networking/firewall.nix
    ../../modules/networking/dns.nix
    ../../modules/networking/wait-online.nix
    ../../modules/networking/tailscale.nix

    ../../modules/security/sudo.nix
    ../../modules/security/gpg.nix

    # ../../modules/apps/firefox.nix
    ../../modules/apps/zen-browser.nix
    ../../modules/apps/spotify.nix
    ../../modules/apps/obsidian.nix
    ../../modules/apps/steam.nix
    ../../modules/apps/slack.nix

    # ../../modules/graphical/wm/hyprland.nix
    ../../modules/graphical/wm/niri
    ../../modules/graphical/displayManager.nix
    ../../modules/graphical/nvidia.nix
    ../../modules/graphical/fonts.nix

    ../../modules/editors/git.nix
    ../../modules/editors/helix

    ../../modules/terminal/wezterm
    ../../modules/terminal/ghostty
    ../../modules/terminal/shell/zsh
    ../../modules/terminal/shell/aliases.nix

    ../../modules/peripherals/audio.nix
    ../../modules/peripherals/bluetooth.nix
    ../../modules/peripherals/keyboard.nix

    ../../modules/users/primary.nix
  ];

  networking.networkmanager.ensureProfiles.profiles."home".ipv4.address = "192.168.0.50/24";

  home-manager.users.${vars.PRIMARY_USER.NAME} = _: {
    programs.niri.settings = {
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

  time.timeZone = "/Dublin";

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";

  networking.hostName = "Oxygen";
}
