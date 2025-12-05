{vars, ...}: {
  home-manager.users.${vars.users.primary.name} = {config, ...}: {
    programs.floorp = {
      enable = true;
      # inherit package;
      profiles."${config.home.username}" = {
        id = 0;
        isDefault = true;
        name = config.home.username;
      };
    };

    # home.sessionVariables."BROWSER" = pkgs.lib.getExe package;
  };
}
