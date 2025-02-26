{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    inputs.nixos-facter-modules.nixosModules.facter
    inputs.impermanence.nixosModules.impermanence

    ./disk.nix
  ];
  facter.reportPath = ./facter.json;

  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh.enable = true;
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];

  users.extraUsers.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFlro/QUDlDpaA1AQxdWIqBg9HSFJf9Cb7CPdsh0JN7"
  ];

  environment.systemPackages = with pkgs; [
    vim
    htop
    git
    rsync
    (pkgs.writeShellScriptBin "connect-wifi" ''
      nmcli device wifi connect VM2888317 password cedkkdJzbxzgxe2a
    '')
  ];

  services.xserver = {
    xkb = {
      options = "ctrl:swapcaps";
      layout = lib.mkDefault "gb";
    };
  };
  console.useXkbConfig = true;
  networking = {
    networkmanager.enable = true;
    wireless.enable = false;
  };

  services.getty = {
    autologinUser = "padraic";
    autologinOnce = true;
    greetingLine = ""; # TODO ASCII ART THIS
    helpLine = "";
  };

  users.users.padraic = {
    isNormalUser = true;
    createHome = true;

    # passwordFile = config.sops.secrets."user@${name}".path;
    # TODO Figure out why sops is not working for this on first installation?
    hashedPassword = "$6$7RhoYiLu0Xn50HZD$pOIypZUz6aALwRt4SlsckKmTFo0r6fHh5zbSTLBQGkrPuoJS.7bJirx936XensJSlkn0e472nKjzE7Y4tv7td0";
    group = "users";

    extraGroups = [
      "wheel"
      "input"
      "networkmanager"
      "audio"
      "pipewire"
      "video"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFlro/QUDlDpaA1AQxdWIqBg9HSFJf9Cb7CPdsh0JN7"
    ];
  };

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = config.system.nixos.version;

  networking.hostName = "Oxygen";
}
