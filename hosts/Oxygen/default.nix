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
    ../../modules/networking/wifi.nix
    ../../modules/networking/ssh.nix
    ../../modules/networking/firewall.nix
    ../../modules/networking/dns.nix
    ../../modules/security/sudo.nix
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
  ];

  services.xserver = {
    xkb = {
      options = "ctrl:swapcaps";
      layout = lib.mkDefault "gb";
    };
  };
  console.useXkbConfig = true;

  services.getty = {
    autologinUser = vars.PRIMARY_USER.NAME;
    autologinOnce = true;
  };

  sops.secrets."${vars.PRIMARY_USER.NAME}_password" = {
    neededForUsers = true;
  };

  programs.zsh.enable = true;

  users = {
    mutableUsers = false;
    users."${vars.PRIMARY_USER.NAME}" = {
      isNormalUser = true;
      createHome = true;
      shell = pkgs.zsh;

      hashedPasswordFile = config.sops.secrets."${vars.PRIMARY_USER.NAME}_password".path;
      group = "users";

      extraGroups = [
        "wheel"
        "input"
        "networkmanager"
        "audio"
        "pipewire"
        "video"
      ];
    };
  };

  home-manager.users.${vars.PRIMARY_USER.NAME} = {
    config,
    osConfig,
    ...
  }: {
    imports = [inputs.secrets.homeModules.default];
    home = {
      homeDirectory = "/home/${vars.PRIMARY_USER.NAME}";
      preferXdgDirectories = true;
      inherit (osConfig.system) stateVersion;
    };

    programs.zsh = {
      enable = true;
      dotDir = ".config/zsh";
      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      enableVteIntegration = true;
      autocd = true;
      historySubstringSearch.enable = true;
      history = {
        expireDuplicatesFirst = true;
        extended = true;
        ignoreDups = true;
        ignorePatterns = [];
        ignoreSpace = true;
        save = 100000;
        share = true;
      };
    };

    # programs.atuin = {
    #   enable = true;
    #   enableZshIntegration = true;
    #   settings = {
    #     daemon.enabled = true;
    #     update_check = false;
    #     sync_address = "https://api.atuin.sh"; # TODO Change
    #     sync_frequency = "15m";
    #     sync.records = true;
    #     dialect = "uk";
    #     key_path = config.sops.secrets.atuin_key.path;
    #   };
    # };

    # sops.secrets.atuin_key = {};
    # systemd.user.services.atuin-daemon = {
    #   Unit = {
    #     Description = "Atuin daemon";
    #     Requires = ["atuin-daemon.socket"];
    #   };
    #   Install = {
    #     Also = ["atuin-daemon.socket"];
    #     WantedBy = ["default.target"];
    #   };
    #   Service = {
    #     ExecStart = "${lib.getExe pkgs.atuin} daemon";
    #     Environment = ["ATUIN_LOG=info"];
    #     Restart = "on-failure";
    #     RestartSteps = 3;
    #     RestartMaxDelaySec = 6;
    #   };
    # };

    # systemd.user.sockets.atuin-daemon = let
    #   socket_dir =
    #     if lib.versionAtLeast pkgs.atuin.version "18.4.0"
    #     then "%t"
    #     else "%D/atuin";
    # in {
    #   Unit = {Description = "Atuin daemon socket";};
    #   Install = {WantedBy = ["sockets.target"];};
    #   Socket = {
    #     ListenStream = "${socket_dir}/atuin.sock";
    #     SocketMode = "0600";
    #     RemoveOnStop = true;
    #   };
    # };
  };

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.11";

  networking.hostName = "Oxygen";
}
