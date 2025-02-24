{
  self,
  inputs,
  l,
  ...
}: let
  inherit (l) nixosSystem;

  # system = "${self}/system";
  # users = "${self}/users";
  # hosts = "${self}/hosts";
  # home = "${self}/home";
  # secrets = "${self}/secrets";

  specialArgs = {
    inherit inputs;
    inherit l;
    # inherit home;
    # inherit hosts;
    inherit self;
  };

  common = [
    # {
    #   nixpkgs.overlays = [
    #     inputs.nur.overlay
    #     inputs.emacs.overlay
    #     inputs.nil.overlays.default
    #   ];
    # }

    # "${system}"
    # "${system}/boot/systemd.nix"
    # "${system}/fs/zfs-persist.nix"

    # "${system}/graphical/stylix.nix"

    # "${system}/hardware/nvidia.nix"
    # "${system}/hardware/keyboard.nix"
    # "${system}/hardware/audio.nix"
    # "${system}/hardware/bluetooth.nix"
    # "${system}/hardware/yubikey.nix"
    # "${system}/hardware/ledger.nix"
    # "${system}/hardware/external-disks.nix"

    # "${system}/networking/tailscale.nix"

    # "${system}/virtualisation/docker.nix"

    # "${users}"
    # "${users}/padraic.nix"

    # "${secrets}"
  ];
in {
  flake.nixosConfigurations = {
    Oxygen = nixosSystem {
      inherit specialArgs;
      modules = [./Oxygen] ++ common;
    };

    Helium =
      nixosSystem {
      };
  };
}
