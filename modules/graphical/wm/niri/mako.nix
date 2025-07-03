{vars, ...}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {pkgs, ...}: {
    home.packages = [
      pkgs.libnotify
    ];

    services.mako = {
      enable = true;
      settings = {};
    };
  };
}
