{
  pkgs,
  lib,
  ...
}: {
  nixpkgs.config.allowBroken = true;

  boot.supportedFilesystems = lib.mkForce ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs"];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [
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
  hardware.bluetooth.enable = false;
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  nixpkgs.config.allowUnfree = true;

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

  users.users.root = {
    initialPassword = "root";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFlro/QUDlDpaA1AQxdWIqBg9HSFJf9Cb7CPdsh0JN7"
    ];
  };

  security.sudo.wheelNeedsPassword = false;
  services.getty.autologinUser = lib.mkForce "root";

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];

  time.timeZone = "Europe/Dublin";

  system.stateVersion = "25.05";

  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
}
