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
      inputs.secrets.nixosModules.default
      (
        {
          pkgs,
          lib,
          vars,
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
            networkmanager = {
              enable = true;
              ensureProfiles = {
                home-wifi = {
                  connection = {
                    id = vars.WIFI.SSID;
                    type = "wifi";
                  };
                  ipv4 = {
                    method = "auto";
                  };
                  ipv6 = {
                    addr-gen-mode = "default";
                    method = "auto";
                  };
                  wifi = {
                    mode = "infrastructure";
                    ssid = vars.WIFI.SSID;
                  };
                  wifi-security = {
                    auth-alg = "open";
                    key-mgmt = "wpa-psk";
                    psk = vars.WIFI.SSID;
                  };
                };
              };
            };
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
