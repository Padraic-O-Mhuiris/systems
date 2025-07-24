_: {
  boot.loader = {
    systemd-boot = {
      enable = true;
      # When set to true, allows access to kernel cli enabling root access
      editor = false;
      timeout = 5;
      configurationLimit = 100;
    };
    efi.canTouchEfiVariables = true;
  };
}
