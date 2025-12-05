{vars, ...}: {
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    autoLogin = {
      enable = true;
      user = vars.users.primary.name;
    };
  };

  # if no display we still want to login to tty
  services.getty = {
    autologinUser = vars.users.primary.name;
    autologinOnce = true;
  };
}
