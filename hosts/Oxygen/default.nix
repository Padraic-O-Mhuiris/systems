{
  inputs,
  vars,
  ...
}: {
  imports = [
    inputs.nixos-facter-modules.nixosModules.facter
    inputs.secrets.nixosModules.default

    ./disk.nix

    ../../modules/common/home-manager.nix
    ../../modules/common/nix
    ../../modules/common/boot.nix
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
    ../../modules/graphical/nvidia.nix
    ../../modules/graphical/fonts.nix

    ../../modules/editors/git
    ../../modules/editors/helix

    ../../modules/terminal/wezterm
    ../../modules/terminal/shell/zsh
    ../../modules/terminal/shell/aliases.nix

    ../../modules/peripherals/audio.nix
    ../../modules/peripherals/bluetooth.nix
    ../../modules/peripherals/keyboard.nix

    ../../modules/users/primary.nix
  ];

  programs.nix-ld.enable = true;

  facter.reportPath = ./facter.json;

  networking.ensureProfiles."home".ipv4.address = "192.168.0.50/24";

  # Relevant if using tty
  services.getty = {
    autologinUser = vars.PRIMARY_USER.NAME;
    autologinOnce = true;
  };

  security.pam.services.sddm.enableGnomeKeyring = true;

  services.displayManager = {
    defaultSession = "niri";
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    autoLogin = {
      enable = true;
      user = vars.PRIMARY_USER.NAME;
    };
  };

  home-manager = {
    users.${vars.PRIMARY_USER.NAME} = _: {
      imports = [
        inputs.secrets.homeModules.default
      ];

      wayland.windowManager.hyprland.settings = {
        monitor = [
          "HDMI-A-1, 1920x1080@60, 0x0, 1"
          "DP-1, 5120x1440@60, 1920x0, 1"
        ];
      };
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";

  networking.hostName = "Oxygen";
}
