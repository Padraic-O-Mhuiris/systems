{vars, ...}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {
    config,
    pkgs,
    lib,
    ...
  }: {
    home.sessionVariables = {
      TERMINAL = lib.getExe pkgs.wezterm;
    };

    xdg.configFile."wezterm/wezterm.lua".source = config.lib.file.mkOutOfStoreSymlink "$HOME/systems/modules/terminal/wezterm/wezterm.lua";
  };
}
