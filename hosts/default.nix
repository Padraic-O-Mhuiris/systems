{
  self,
  inputs,
  ...
}: let
  inherit (self) lib root;

  specialArgs = {
    inherit inputs;
    inherit lib;
    inherit root;
  };

  common = [
    ../modules/ai

    ../modules/common/home-manager.nix
    ../modules/common/nix
    ../modules/common/facter.nix
    ../modules/common/boot.nix
    ../modules/common/pkgs.nix
    ../modules/common/impermanence.nix

    ../modules/networking/ssh.nix
    ../modules/networking/firewall.nix
    ../modules/networking/dns.nix
    ../modules/networking/wait-online.nix
    ../modules/networking/tailscale.nix
    ../modules/networking/wifi.nix

    ../modules/security/sudo.nix
    ../modules/security/gpg.nix

    # ../modules/apps/firefox.nix
    ../modules/apps/zen-browser.nix
    ../modules/apps/spotify.nix
    ../modules/apps/obsidian.nix
    ../modules/apps/steam.nix
    ../modules/apps/qbittorrent.nix
    ../modules/apps/slack.nix
    ../modules/apps/nemo.nix
    ../modules/apps/telegram.nix
    ../modules/apps/libreoffice.nix

    ../modules/graphical/wm/niri
    ../modules/graphical/displayManager.nix
    ../modules/graphical/nvidia.nix
    ../modules/graphical/fonts.nix

    ../modules/editors/git.nix
    ../modules/editors/helix

    ../modules/terminal/wezterm
    ../modules/terminal/ghostty
    ../modules/terminal/shell/zsh
    ../modules/terminal/shell/atuin.nix
    ../modules/terminal/shell/aliases.nix

    ../modules/virtualisation

    ../modules/peripherals/audio.nix
    ../modules/peripherals/bluetooth.nix
    ../modules/peripherals/keyboard.nix
    ../modules/peripherals/usb.nix

    ../modules/users/primary.nix
  ];
in {
  flake.nixosConfigurations = {
    Oxygen = lib.nixosSystem {
      inherit specialArgs;
      modules =
        [
          ./Oxygen
          ../modules/peripherals/monitors.nix
        ]
        ++ common;
    };
    Hydrogen = lib.nixosSystem {
      inherit specialArgs;
      modules =
        [
          ./Hydrogen
          ../modules/graphical/temperature.nix
        ]
        ++ common;
    };
  };

  perSystem = _: {
    packages.Lithium =
      (lib.nixosSystem {
        inherit specialArgs;
        modules = [
          ./Lithium
        ];
      }).config.system.build.isoImage;
  };
}
