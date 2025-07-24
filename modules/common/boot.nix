_: {
  boot.loader = {
    systemd-boot = {
      enable = true;
      timeout = 5;
      configurationLimit = 100;
    };
    efi.canTouchEfiVariables = true;
  };
}
