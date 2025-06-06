{
  inputs,
  lib,
  pkgs,
  config,
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
    ../../modules/networking/wait-online.nix
    ../../modules/security/sudo.nix
    ../../modules/security/gpg.nix
    ../../modules/apps/firefox.nix
    # ../../modules/graphical/wm/hyprland.nix
    ../../modules/graphical/wm/niri
    ../../modules/graphical/fonts.nix
    ../../modules/editors/helix
    ../../modules/terminal/wezterm
    ../../modules/terminal/shell/zsh
    ../../modules/git.nix
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
    btop
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

  nixpkgs = {
    config.allowUnfree = lib.mkDefault true;
  };

  nix = {
    # pin the registry to avoid downloading and evaling a new nixpkgs version every time
    registry = lib.mapAttrs (_: v: {flake = v;}) inputs;

    package = pkgs.nixVersions.nix_2_23;

    # set the path for channels compat
    nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry;

    settings = {
      auto-optimise-store = true;
      builders-use-substitutes = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      flake-registry = "/etc/nix/registry.json";

      # for direnv GC roots
      keep-derivations = true;
      keep-outputs = true;

      trusted-users = [
        "root"
        "@wheel"
      ];
      substituters = ["https://cache.nixos.org?priority=10"];
      trusted-substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://numtide.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      ];
    };
  };

  services.displayManager = {
    defaultSession = "niri";
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    autoLogin = {
      enable = true;
      user = vars.PRIMARY_USER.NAME;
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = false;
    backupFileExtension = "backup";
    verbose = true;

    users.${vars.PRIMARY_USER.NAME} = {
      config,
      osConfig,
      ...
    }: {
      imports = [inputs.secrets.homeModules.default];
      home = {
        homeDirectory = "/home/${vars.PRIMARY_USER.NAME}";
        preferXdgDirectories = true;
        inherit (osConfig.system) stateVersion;
        shellAliases = {
          # TODO Create default filesystem location for this nixos repository
          "nr" = "sudo nixos-rebuild --flake $HOME/systems#${osConfig.networking.hostName} switch --show-trace --verbose";
        };
      };

      wayland.windowManager.hyprland.settings = {
        monitor = [
          "HDMI-A-1, 1920x1080@60, 0x0, 1"
          "DP-1, 5120x1440@60, 1920x0, 1"
        ];
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
  system.stateVersion = "25.05";

  networking.hostName = "Oxygen";
}
