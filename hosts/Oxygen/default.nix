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
    ../../modules/networking/tailscale.nix

    ../../modules/security/sudo.nix
    ../../modules/security/gpg.nix

    # ../../modules/apps/firefox.nix
    ../../modules/apps/zen-browser.nix
    ../../modules/apps/spotify.nix
    ../../modules/apps/obsidian.nix
    ../../modules/apps/steam.nix
    ../../modules/apps/slack.nix

    # ../../modules/graphical/wm/hyprland.nix
    ../../modules/graphical/wm/niri
    ../../modules/graphical/nvidia.nix
    ../../modules/graphical/fonts.nix

    ../../modules/editors/git
    ../../modules/editors/helix

    ../../modules/terminal/wezterm
    ../../modules/terminal/shell/zsh

    ../../modules/peripherals/audio.nix
    ../../modules/peripherals/bluetooth.nix
    ../../modules/peripherals/keyboard.nix

    ../../modules/users/primary.nix
  ];

  programs.nix-ld.enable = true;

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

  networking.ensureProfiles."home".ipv4.address = "192.168.0.50/24";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = with pkgs; [
    vim
    htop
    git
    rsync
    btop
    jq
    wget
    unzip
    bc
    nautilus
    pciutils
  ];

  services.getty = {
    autologinUser = vars.PRIMARY_USER.NAME;
    autologinOnce = true;
  };

  programs.zsh.enable = true;

  nixpkgs = {
    config.allowUnfree = lib.mkDefault true;
  };

  nix = {
    # pin the registry to avoid downloading and evaling a new nixpkgs version every time
    registry = lib.mapAttrs (_: v: {flake = v;}) inputs;

    package = pkgs.nixVersions.nix_2_29;

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

  security.pam.services.sddm.enableGnomeKeyring = true;

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
      imports = [
        inputs.secrets.homeModules.default
      ];

      home = {
        homeDirectory = "/home/${vars.PRIMARY_USER.NAME}";
        preferXdgDirectories = true;
        inherit (osConfig.system) stateVersion;
        shellAliases = {
          # TODO Create default filesystem location for this nixos repository
          "nr" = "sudo nixos-rebuild --flake $HOME/systems#${osConfig.networking.hostName} switch --show-trace --verbose";
        };
      };

      xdg = {
        enable = true;
        userDirs = {
          enable = true;
          createDirectories = true;
          download = "${config.home.homeDirectory}/downloads";
          extraConfig = {
            XDG_CODE_DIR = "${config.home.homeDirectory}/code";
          };
          desktop = null;
          documents = "documents";
          pictures = null;
          publicShare = null;
          templates = null;
          videos = null;
          music = null;
        };
      };

      wayland.windowManager.hyprland.settings = {
        monitor = [
          "HDMI-A-1, 1920x1080@60, 0x0, 1"
          "DP-1, 5120x1440@60, 1920x0, 1"
        ];
      };
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";

  networking.hostName = "Oxygen";
}
