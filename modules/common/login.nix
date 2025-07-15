{vars, ...}: {
  services.displayManager.autoLogin = {
    enable = true;
    user = vars.PRIMARY_USER.NAME;
  };

  services.getty = {
    autologinUser = vars.PRIMARY_USER.NAME;
    autologinOnce = true;
  };

  security.pam.services.sddm.enableGnomeKeyring = true;
}
