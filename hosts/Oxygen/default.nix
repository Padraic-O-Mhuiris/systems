{
  inputs,
  pkgs,
  config,
  lib,
  vars,
  ...
}: {
  imports = [
    inputs.nixos-facter-modules.nixosModules.facter
    inputs.impermanence.nixosModules.impermanence
    inputs.secrets.nixosModules.default
    inputs.home-manager.nixosModules.home-manager

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
      "/var/lib/sudo"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/machine-id"
    ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh.enable = true;
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];

  environment.systemPackages = with pkgs; [
    vim
    htop
    git
    rsync
    (pkgs.writeShellScriptBin "connect-wifi" ''
      nmcli device wifi connect ${vars.WIFI.HOST} password ${vars.WIFI.PASSWORD}
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
    autologinUser = vars.PRIMARY_USER.NAME;
    autologinOnce = true;
  };

  users.extraUsers.root.openssh.authorizedKeys.keys = [
    vars.PRIMARY_USER.SSH_PUBLIC_KEY
  ];

  sops.secrets."primary_user_password".neededForUsers = true;
  users = {
    mutableUsers = false;
    users."${vars.PRIMARY_USER.NAME}" = {
      isNormalUser = true;
      createHome = true;

      hashedPasswordFile = config.sops.secrets."primary_user_password".path;
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
        vars.PRIMARY_USER.SSH_PUBLIC_KEY
      ];
    };
  };

  home-manager = {
    users.${vars.PRIMARY_USER.NAME} = {
      config,
      osConfig,
      ...
    }: {
      imports = [inputs.secrets.homeModules.default];
      home = {
        homeDirectory = "/home/${vars.PRIMARY_USER.NAME}";
        inherit (osConfig.system) stateVersion;
      };
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.11";

  networking.hostName = "Oxygen";
}
