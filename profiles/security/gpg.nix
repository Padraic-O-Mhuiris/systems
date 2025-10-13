# TODO: https://joinemm.dev/blog/yubikey-nixos-guide
{
  pkgs,
  vars,
  ...
}: {
  environment.systemPackages = with pkgs; [
    yubikey-personalization
    yubikey-manager
    usbutils
    lsof
  ];

  # Allows for smartcard detection
  services = {
    pcscd.enable = true;
    udev.packages = with pkgs; [
      yubikey-personalization
      libu2f-host
    ];
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
      scdaemonSettings = {
        pcsc-driver = "${pkgs.pcsclite.lib}/lib/libpcsclite.so";
        disable-ccid = true;
        card-timeout = "10";
        debug-level = "basic";
        log-file = "/tmp/scdaemon.log";
      };
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableExtraSocket = true;
      enableScDaemon = true;
      grabKeyboardAndMouse = true;
      defaultCacheTtl = 3600;
      pinentry.package = pkgs.pinentry-gnome3;
      extraConfig = ''
        allow-loopback-pinentry
      '';
      verbose = true;
    };

    home.packages = with pkgs; [pcsc-tools];

    systemd.user.sessionVariables.GNUPGHOME = "${config.xdg.dataHome}/gnupg";
  };

  users.users.${vars.PRIMARY_USER.NAME}.extraGroups = ["pcscd"];
}
