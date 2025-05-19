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
  services.pcscd.enable = true;
  services.udev.packages = with pkgs; [
    yubikey-personalization
    libu2f-host
  ];

  hardware.gpgSmartcards.enable = true;

  home-manager.users.${vars.PRIMARY_USER.NAME} = {config, ...}: {
    programs.gpg = {
      enable = true;
      mutableKeys = false;
      homedir = "${config.xdg.dataHome}/gnupg";
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
