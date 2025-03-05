# This configuration produces a package "iso" which is an iso image of a base nix configuration image.
# Used in order to bootstrap nixos installations
{
  inputs,
  self,
  ...
}: let
  inherit (inputs) nixpkgs;
  inherit (self) lib;

  iso = lib.nixosSystem {
    specialArgs = {
      inherit inputs;
      inherit lib;
    };

    modules = [
      "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"

      (
        {
          pkgs,
          lib,
          ...
        }: {
          nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
          nixpkgs.config.allowUnfree = true;

          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];
          nix.extraOptions = "experimental-features = nix-command flakes";

          networking = {
            hostName = "iso";
            networkmanager.enable = true;
            wireless.enable = false;
          };

          services.openssh.enable = true;

          services.xserver = {
            xkb = {
              options = "ctrl:swapcaps";
              layout = lib.mkDefault "gb";
            };
          };
          console.useXkbConfig = true;

          environment.systemPackages = with pkgs; [
            vim
            htop
            git
            rsync
          ];

          users.extraUsers.root.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFlro/QUDlDpaA1AQxdWIqBg9HSFJf9Cb7CPdsh0JN7"
          ];

          systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];

          systemd.services.connectToLocalInternet = {
            description = "Connect to local Wi-Fi on boot using nmcli";

            after = ["default.target"];
            wantedBy = ["default.target"];

            script = ''
              #!/usr/bin/env bash
              SSID="VM2888317"
              PASSWORD="cedkkdJzbxzgxe2a"

              for i in {1..30}; do
                if ${pkgs.networkmanager}/bin/nmcli general status &> /dev/null; then
                  echo "NetworkManager is ready."
                  break
                fi
                echo "Waiting for NetworkManager..."
                sleep 1
              done

              echo "Attempting to connect to Wi-Fi: $SSID"
              ${pkgs.networkmanager}/bin/nmcli device wifi connect "$SSID" password "$PASSWORD"
            '';

            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
          };

          system.stateVersion = lib.mkDefault "24.11";

          isoImage.squashfsCompression = "gzip -Xcompression-level 1";
        }
      )
    ];
  };
in {
  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    system,
    ...
  }: {
    packages.iso = iso.config.system.build.isoImage;
  };
}
