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
    system = {inherit (self) homeManagerModules nixosModules packages;};
  };

  common = [
    ../profiles/ai

    ../profiles/common/home-manager.nix
    ../profiles/common/nix
    ../profiles/common/facter.nix
    ../profiles/common/boot.nix
    ../profiles/common/pkgs.nix
    ../profiles/common/impermanence.nix
    ../profiles/common/shutdown.nix

    ../profiles/networking/firewall.nix
    ../profiles/networking/dns.nix
    ../profiles/networking/wait-online.nix
    ../profiles/networking/tailscale.nix
    ../profiles/networking/wifi.nix

    # ../profiles/browsers/firefox.nix
    # ../profiles/browsers/google-chrome.nix
    # ../profiles/browsers/zen-browser.nix
    ../profiles/browsers/librewolf
    # ../profiles/browsers/floorp.nix

    ../profiles/apps/spotify.nix
    ../profiles/apps/obsidian.nix
    ../profiles/apps/steam.nix
    ../profiles/apps/qbittorrent.nix
    ../profiles/apps/slack.nix
    ../profiles/apps/nemo.nix
    ../profiles/apps/telegram.nix
    ../profiles/apps/libreoffice.nix

    ../profiles/graphical/wm/niri
    ../profiles/graphical/displayManager.nix
    ../profiles/graphical/nvidia.nix
    ../profiles/graphical/fonts.nix

    ../profiles/vcs/git.nix
    ../profiles/vcs/jujutsu.nix

    ../profiles/editors/helix

    ../profiles/terminal/wezterm
    ../profiles/terminal/ghostty
    ../profiles/terminal/shell/zsh
    ../profiles/terminal/shell/atuin.nix
    ../profiles/terminal/shell/aliases.nix

    ../profiles/virtualisation

    ../profiles/peripherals/audio.nix
    ../profiles/peripherals/bluetooth.nix
    ../profiles/peripherals/keyboard.nix
    ../profiles/peripherals/usb.nix

    ../profiles/users/primary.nix
  ];
in {
  flake.nixosConfigurations = {
    Oxygen = lib.nixosSystem {
      inherit specialArgs;
      modules =
        [
          ./Oxygen
          ../profiles/peripherals/monitors.nix
        ]
        ++ common;
    };
    Hydrogen = lib.nixosSystem {
      inherit specialArgs;
      modules =
        [
          ./Hydrogen
          ../profiles/hardware/battery.nix
          ../profiles/graphical/temperature.nix
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
