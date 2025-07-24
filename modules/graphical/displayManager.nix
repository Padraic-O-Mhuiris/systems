{vars, ...}: {
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    autoLogin = {
      enable = true;
      user = vars.PRIMARY_USER.NAME;
    };
  };
}
