{vars, ...}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {config, ...}: {
    programs.librewolf = {
      enable = true;
      profiles."${config.home.username}" = {
        id = 0;
        isDefault = true;
        name = config.home.username;
      };
    };
  };
}
