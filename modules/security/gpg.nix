{
  pkgs,
  vars,
  ...
}: {
  environment.systemPackages = with pkgs; [
    yubikey-personalization
    yubikey-manager
  ];

  # Allows for smartcard detection
  services = {
    pcscd.enable = true;
    udev.packages = with pkgs; [
      yubikey-personalization
      libu2f-host
    ];
    yubikey-agent.enable = true;
  };

  hardware.gpgSmartcards.enable = true;

  home-manager.users.${vars.PRIMARY_USER.NAME} = {config, ...}: {
    programs.gpg = {
      enable = true;
      mutableKeys = false;
      homedir = "${config.xdg.dataHome}/gnupg";
      publicKeys = [
        {
          text = vars.PRIMARY_USER.GPG_PUBLIC_KEY;
          trust = 5;
        }
      ];
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableExtraSocket = true;
      enableScDaemon = true;
      grabKeyboardAndMouse = true;
      defaultCacheTtl = 3600;
      pinentryPackage = pkgs.pinentry-gnome3;
      extraConfig = ''
        allow-loopback-pinentry
      '';
      verbose = true;
    };

    home.packages = with pkgs; [pcsc-tools];

    systemd.user.sessionVariables.GNUPGHOME = "${config.xdg.dataHome}/gnupg";
  };
}
