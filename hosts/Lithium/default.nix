{
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    inputs.secrets.nixosModules.wifi-home
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
  ];

  nixpkgs = {
    config = {
      allowBroken = true;
      allowUnfree = true;
    };
    hostPlatform = lib.mkDefault "x86_64-linux";
  };

  boot = {
    supportedFilesystems = lib.mkForce ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs"];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [
    "brcmfmac"
    "brcmutil"
    "iwlmvm"
    "iwlwifi"
    "mmc_core"
    "mt76_usb"
    "mt76"
    "mt76x0_common"
    "mt76x02_lib"
    "mt76x02_usb"
    "mt76x0u"
    "r8188eu"
    "rtl_usb"
    "rtl8192c_common"
    "rtl8192cu"
    "rtlwifi"
    ];
  };
  hardware.bluetooth.enable = false;
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;


  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.extraOptions = "experimental-features = nix-command flakes";

  networking = {
    hostName = "Lithium";
    networkmanager.ensureProfiles.profiles."home".ipv4.address = "192.168.0.52/24";
    wireless.enable = false;
  };

  services = {
    openssh.enable = true;

    xserver = {
      xkb = {
        options = "ctrl:swapcaps";
        layout = lib.mkDefault "gb";
      };
    };

    getty.autologinUser = lib.mkForce "root";
  };

  console.useXkbConfig = true;

  environment.systemPackages = with pkgs; [
    vim
    htop
    git
    rsync
  ];

  users = {
    mutableUsers = false;
    users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFlro/QUDlDpaA1AQxdWIqBg9HSFJf9Cb7CPdsh0JN7"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];

  time.timeZone = "Europe/Dublin";

  system.stateVersion = "25.05";

  # isoImage.squashfsCompression = "gzip -Xcompression-level 1";
}
