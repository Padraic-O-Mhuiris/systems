{vars, ...}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {pkgs, ...}: {
    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings = {
        color = "808080";
        font-size = 24;
        indicator-idle-visible = false;
        indicator-radius = 100;
        line-color = "ffffff";
        show-failed-attempts = true;
        effect-blur = "7x5"; # Blur effect
        effect-vignette = "0.5:0.5"; # Vignette effect
        ring-color = "3b4252";
        key-hl-color = "880033";
        inside-color = "00000088";
        separator-color = "00000000";
      };
    };
  };
}
