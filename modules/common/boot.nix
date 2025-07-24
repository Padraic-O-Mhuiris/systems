_: {
  boot.loader = {
    systemd-boot = {
      enable = true;
      # When set to true, allows access to kernel cli enabling root access
      editor = false;
      configurationLimit = 100;
    };
    efi.canTouchEfiVariables = true;
  };
}
